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

  # Unité de saisie : doit être dans Units::VALID_UNITS
  validates :quantity_unit,
            presence: true,
            inclusion: { in: Units::VALID_UNITS }

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

  # Poids effectif (réhydraté si produit déshydraté)
  def effective_weight_kg
    return quantity_kg unless product_component?
    return quantity_kg unless component&.dehydrated?

    quantity_kg * (component.rehydration_coefficient || 1)
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

  # 3 niveaux max de sous-recettes : A → B → C → D autorisé, A → B → C → D → E interdit
  def validate_max_depth
    return unless component.is_a?(Recipe)

    # Sens descendant : la sous-recette ajoutée ne doit pas être déjà à profondeur 3
    if depth_below(component) >= 3
      errors.add(:base, "La sous-recette '#{component.name}' atteint déjà la profondeur maximale (3 niveaux max)")
      return
    end

    # Sens ascendant + descendant : la profondeur totale ne doit pas dépasser 3
    if depth_above(parent_recipe) + depth_below(component) >= 3
      errors.add(:base, "Ajout impossible : la profondeur totale dépasserait 3 niveaux")
    end
  end

  def depth_below(recipe)
    child_recipe_ids = recipe.recipe_components.where(component_type: 'Recipe').pluck(:component_id)
    return 0 if child_recipe_ids.empty?

    grandchild_ids = RecipeComponent.where(component_type: 'Recipe', parent_recipe_id: child_recipe_ids).pluck(:component_id)
    return 1 if grandchild_ids.empty?

    great_grandchild_exists = RecipeComponent.where(component_type: 'Recipe', parent_recipe_id: grandchild_ids).exists?
    great_grandchild_exists ? 3 : 2
  end

  def depth_above(recipe)
    parent_ids = RecipeComponent.where(component_type: 'Recipe', component_id: recipe.id).pluck(:parent_recipe_id)
    return 0 if parent_ids.empty?

    grandparent_ids = RecipeComponent.where(component_type: 'Recipe', component_id: parent_ids).pluck(:parent_recipe_id)
    return 1 if grandparent_ids.empty?

    great_grandparent_exists = RecipeComponent.where(component_type: 'Recipe', component_id: grandparent_ids).exists?
    great_grandparent_exists ? 3 : 2
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
