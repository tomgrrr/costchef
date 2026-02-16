# frozen_string_literal: true

class RecipeComponent < ApplicationRecord
  # ============================================
  # PRD Section 6.7 : Table RECIPE_COMPONENTS
  # Composants polymorphes : Product OU Recipe
  # ============================================

  # ============================================
  # Associations
  # ============================================
  belongs_to :parent_recipe, class_name: 'Recipe'

  # Polymorphisme: peut être Product ou Recipe
  belongs_to :component, polymorphic: true

  # ============================================
  # Validations (PRD Section 6.7 & 8.3)
  # ============================================

  # Quantité en kg > 0
  validates :quantity_kg,
            presence: true,
            numericality: { greater_than: 0 }

  # Type de composant valide
  validates :component_type,
            presence: true,
            inclusion: { in: %w[Product Recipe] }

  # D9: Unicité stricte - un même produit/sous-recette ne peut apparaître qu'une fois
  validates :component_id,
            uniqueness: {
              scope: [:parent_recipe_id, :component_type],
              message: "est déjà présent dans cette recette"
            }

  # ============================================
  # Validations métier avancées
  # ============================================
  validate :validate_subrecipe_is_sellable, if: :recipe_component?
  validate :validate_max_depth, if: :recipe_component?
  validate :validate_no_self_reference, if: :recipe_component?
  validate :validate_no_circular_reference, if: :recipe_component?
  validate :validate_same_user

  # ============================================
  # Instance Methods
  # ============================================

  def recipe_component?
    component_type == 'Recipe'
  end

  def product_component?
    component_type == 'Product'
  end

  # Coût de la ligne (PRD Section 8.1)
  def line_cost
    return 0 unless quantity_kg && component

    if product_component?
      quantity_kg * (component.avg_price_per_kg || 0)
    else
      quantity_kg * (component.cached_cost_per_kg || 0)
    end
  end

  private

  # PRD Section 6.7: Le composant Recipe doit avoir sellable_as_component = true
  def validate_subrecipe_is_sellable
    return unless component.is_a?(Recipe)

    unless component.sellable_as_component?
      errors.add(:base, "La recette '#{component.name}' n'est pas marquée comme utilisable en sous-recette")
    end
  end

  # PRD D5: 1 seul niveau max - la sous-recette ne doit pas contenir d'autres sous-recettes
  def validate_max_depth
    return unless component.is_a?(Recipe)

    if component.recipe_components.where(component_type: 'Recipe').exists?
      errors.add(:base, "La sous-recette '#{component.name}' contient déjà des sous-recettes (1 niveau max)")
    end
  end

  # Anti-cycle: une recette ne peut pas se contenir elle-même
  def validate_no_self_reference
    if component_id == parent_recipe_id && component_type == 'Recipe'
      errors.add(:base, "Une recette ne peut pas se contenir elle-même")
    end
  end

  # Anti-cycle avancé: vérifier les références circulaires
  def validate_no_circular_reference
    return unless component.is_a?(Recipe)

    # Vérifie si la sous-recette contient notre recette parente comme composant
    if component.recipe_components.exists?(component_type: 'Recipe', component_id: parent_recipe_id)
      errors.add(:base, "Référence circulaire détectée: '#{component.name}' contient déjà cette recette")
    end
  end

  # Le composant doit appartenir au même utilisateur
  def validate_same_user
    return unless parent_recipe && component

    component_user_id = component.respond_to?(:user_id) ? component.user_id : nil

    if component_user_id && component_user_id != parent_recipe.user_id
      errors.add(:component, "doit appartenir au même utilisateur")
    end
  end
end
