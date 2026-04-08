# frozen_string_literal: true

class Product < ApplicationRecord
  # ============================================
  # PRD Section 6.3 : Table PRODUCTS
  # ============================================

  # ============================================
  # Associations
  # ============================================
  belongs_to :user

  # PRD: Un produit a plusieurs achats. CASCADE sur suppression produit.
  has_many :product_purchases, dependent: :destroy

  # PRD: Utilisation dans les recettes via polymorphisme
  # RESTRICT: impossible de supprimer si utilisé dans une recette
  has_many :recipe_components, as: :component, dependent: :restrict_with_error

  # ============================================
  # Validations (PRD Section 6.3 & 8.3)
  # ============================================

  # Nom unique par utilisateur
  validates :name, presence: true, uniqueness: { scope: :user_id }

  # Unité de base : kg, l, piece uniquement
  validates :base_unit, presence: true, inclusion: { in: %w[kg l piece] }

  # D14: Prix moyen >= 0, jamais nil, défaut 0
  validates :avg_price_per_kg,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  # D6: unit_weight_kg obligatoire et > 0 si base_unit='piece', NULL sinon
  validates :unit_weight_kg,
            presence: true,
            numericality: { greater_than: 0 },
            if: :piece_unit?

  validates :unit_weight_kg,
            absence: true,
            unless: :piece_unit?

  # Déshydratation : coefficient obligatoire et > 1 si dehydrated, uniquement pour kg
  validates :rehydration_coefficient,
            numericality: { greater_than: 1 },
            presence: true,
            if: :dehydrated?

  validate :dehydrated_only_for_kg

  # ============================================
  # Callbacks
  # ============================================
  after_initialize :set_defaults, if: :new_record?
  before_validation :clear_dehydration_fields, unless: :dehydrated?

  # ============================================
  # Instance Methods
  # ============================================

  def piece_unit?
    base_unit == 'piece'
  end

  # Vérifie si le produit est utilisé dans des recettes
  def used_in_recipes?
    recipe_components.exists?
  end

  # Nombre de recettes utilisant ce produit
  def recipes_count
    recipe_components.count
  end

  # Liste des recettes parentes (dédupliquées, triées par nom)
  def used_in_recipes
    recipe_components.includes(:parent_recipe).map(&:parent_recipe).uniq.sort_by(&:name)
  end

  # Moyenne arithmétique simple des price_per_kg des achats actifs
  def simple_avg_price_per_kg
    avg = product_purchases.active.average(:price_per_kg)
    avg ? avg.round(2) : 0
  end

  def high_variability?
    cv = Products::VariabilityCalculator.call(self)
    return false if cv.nil?

    cv > user.price_variability_threshold
  end

  private

  def set_defaults
    self.base_unit ||= 'kg'
    self.avg_price_per_kg ||= 0
  end

  def dehydrated_only_for_kg
    if dehydrated? && base_unit != 'kg'
      errors.add(:dehydrated, "n'est disponible que pour les produits en kg")
    end
  end

  def clear_dehydration_fields
    self.rehydration_coefficient = nil
  end
end
