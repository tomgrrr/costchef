class RecipeComponent < ApplicationRecord
  belongs_to :parent_recipe, class_name: 'Recipe'

  # Polymorphisme: peut être Product ou Recipe
  belongs_to :component, polymorphic: true

  # Validations de base
  validates :quantity_kg, presence: true, numericality: { greater_than: 0 }

  # Unicité stricte (D9) : Un même produit ne peut apparaître qu'une fois dans une recette
  validates :component_id, uniqueness: { scope: [:parent_recipe_id, :component_type], message: "est déjà présent dans la recette" }

  # Validations Métier Avancées (Section 6.7 & 8.3)
  validate :validate_component_type
  validate :validate_max_depth, if: -> { component_type == 'Recipe' }
  validate :validate_no_self_reference, if: -> { component_type == 'Recipe' }
  validate :validate_sellable_as_component, if: -> { component_type == 'Recipe' }

  private

  def validate_component_type
    unless %w[Product Recipe].include?(component_type)
      errors.add(:component_type, "doit être un Produit ou une Recette")
    end
  end

  # D5: 1 seul niveau max
  def validate_max_depth
    # Si le composant est une recette, cette sous-recette ne doit pas avoir elle-même de sous-recettes (composants de type Recipe)
    sub_recipe = Recipe.find_by(id: component_id)
    if sub_recipe && sub_recipe.recipe_components.where(component_type: 'Recipe').exists?
      errors.add(:base, "La sous-recette '#{sub_recipe.name}' contient déjà des sous-recettes. Imbrication maximale atteinte (1 niveau).")
    end
  end

  # Anti-cycle
  def validate_no_self_reference
    if component_id == parent_recipe_id
      errors.add(:base, "Une recette ne peut pas se contenir elle-même.")
    end
    # Note: Une vérification de cycle plus profonde pourrait être nécessaire si on augmentait la profondeur,
    # mais avec 1 niveau max, celle-ci + validate_max_depth suffisent souvent.
  end

  # Règle explicite section 6.7
  def validate_sellable_as_component
    sub_recipe = Recipe.find_by(id: component_id)
    if sub_recipe && !sub_recipe.sellable_as_component
      errors.add(:base, "La recette '#{sub_recipe.name}' n'est pas marquée comme utilisable en tant que sous-recette.")
    end
  end
end
