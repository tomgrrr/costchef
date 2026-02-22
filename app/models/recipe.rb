# frozen_string_literal: true

class Recipe < ApplicationRecord
  # ============================================
  # PRD Section 6.6 : Table RECIPES
  # ============================================

  # ============================================
  # Associations
  # ============================================
  belongs_to :user
  belongs_to :tray_size, optional: true

  # Composants de CETTE recette (ses ingrédients)
  has_many :recipe_components,
           foreign_key: :parent_recipe_id,
           inverse_of: :parent_recipe,
           dependent: :destroy

  # Endroits où CETTE recette est utilisée comme sous-recette
  # RESTRICT: impossible de supprimer si utilisée comme sous-recette
  has_many :parent_recipe_components,
           as: :component,
           class_name: 'RecipeComponent',
           dependent: :restrict_with_error

  # ============================================
  # Associations helpers (PRD Section 6.6)
  # ============================================

  # Accès direct aux produits utilisés dans cette recette
  has_many :products,
           through: :recipe_components,
           source: :component,
           source_type: 'Product'

  # ============================================
  # Scopes
  # ============================================

  # PRD D5: Recettes utilisables comme sous-recettes
  scope :usable_as_subrecipe, -> { where(sellable_as_component: true) }

  # Tri par coût au kilo (PRD Module 5)
  scope :by_cost_per_kg, -> { order(:cached_cost_per_kg) }
  scope :by_cost_per_kg_desc, -> { order(cached_cost_per_kg: :desc) }

  # ============================================
  # Validations (PRD Section 6.6 & 8.3)
  # ============================================

  # Nom unique par utilisateur
  validates :name, presence: true, uniqueness: { scope: :user_id }

  # Description optionnelle, max 2000 caractères
  validates :description, length: { maximum: 2000 }, allow_nil: true

  # Perte cuisson entre 0 et 100%
  validates :cooking_loss_percentage,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 100
            },
            allow_nil: true

  # Champs cached (calculés par le service Recalculator)
  validates :cached_total_cost,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  validates :cached_raw_weight,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  validates :cached_total_weight,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  validates :cached_cost_per_kg,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  # ============================================
  # Validations personnalisées
  # ============================================
  validate :tray_size_consistency
  validate :tray_size_belongs_to_same_user
  validate :subrecipe_cannot_have_tray

  # ============================================
  # Callbacks
  # ============================================
  after_initialize :set_defaults, if: :new_record?

  # ============================================
  # Instance Methods
  # ============================================

  # Alias lisible de sellable_as_component?
  def subrecipe?
    sellable_as_component?
  end

  # Vérifie si la recette est utilisée comme sous-recette ailleurs
  def used_as_subrecipe?
    parent_recipe_components.exists?
  end

  # Nombre de recettes parentes
  def parent_recipes_count
    parent_recipe_components.count
  end

  # Vérifie si la recette contient des sous-recettes
  def has_subrecipes?
    recipe_components.where(component_type: 'Recipe').exists?
  end

  # Composants de type Product uniquement
  def product_components
    recipe_components.where(component_type: 'Product')
  end

  # Composants de type Recipe (sous-recettes) uniquement
  def subrecipe_components
    recipe_components.where(component_type: 'Recipe')
  end

  # ============================================
  # Méthodes de calcul (utilisées par le service Recalculator)
  # ============================================

  # Poids brut total (somme des quantity_kg de tous les composants)
  def calculated_raw_weight
    recipe_components.sum(:quantity_kg)
  end

  # Poids total après cuisson (avec perte)
  def calculated_total_weight
    raw = calculated_raw_weight
    return BigDecimal('0') if raw.zero?

    loss_pct = cooking_loss_percentage || 0
    raw * (1 - loss_pct / BigDecimal('100'))
  end

  # Coût total (somme des line_cost de tous les composants)
  def calculated_total_cost
    recipe_components.includes(:component).sum(&:line_cost)
  end

  # Coût au kilo
  def calculated_cost_per_kg
    weight = calculated_total_weight
    return BigDecimal('0') if weight.zero?

    calculated_total_cost / weight
  end

  # ============================================
  # Prix de vente
  # ============================================

  # Prix de vente conseillé (PRD Section 8.1)
  # Sans barquette: cost_per_kg * coefficient
  # Avec barquette: (cost_per_kg * coefficient) + tray_price
  def suggested_selling_price
    return nil unless cached_cost_per_kg && user&.markup_coefficient

    base_price = cached_cost_per_kg * user.markup_coefficient

    if has_tray && tray_size&.price
      base_price + tray_size.price
    else
      base_price
    end
  end

  private

  def set_defaults
    self.cooking_loss_percentage ||= 0
    self.sellable_as_component ||= false
    self.has_tray ||= false
  end

  # Une sous-recette ne peut pas avoir de barquette
  def subrecipe_cannot_have_tray
    if sellable_as_component && (has_tray || tray_size_id.present?)
      errors.add(:has_tray, 'Une sous-recette ne peut pas avoir de barquette')
    end
  end

  # PRD: Si barquette activée, une taille doit être sélectionnée
  def tray_size_consistency
    if has_tray && tray_size_id.nil?
      errors.add(:tray_size_id, "doit être sélectionnée si l'option barquette est active")
    end
  end

  # La taille de barquette doit appartenir au même utilisateur
  def tray_size_belongs_to_same_user
    return unless tray_size && user

    if tray_size.user_id != user_id
      errors.add(:tray_size, "doit appartenir au même utilisateur")
    end
  end
end
