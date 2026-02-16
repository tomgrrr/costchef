# frozen_string_literal: true

class Recipe < ApplicationRecord
  belongs_to :user
  belongs_to :tray_size, optional: true

  # Composants de CETTE recette (ingrédients)
  has_many :recipe_components, foreign_key: :parent_recipe_id, dependent: :destroy

  # Endroits où CETTE recette est utilisée comme sous-recette (inverse du polymorphisme)
  has_many :parent_recipe_components, as: :component, class_name: 'RecipeComponent', dependent: :restrict_with_error

  # Validations
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :cooking_loss_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  # Validations des champs cachés (Section 6.6)
  validates :cached_total_cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :cached_cost_per_kg, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Validation Barquette
  validate :tray_size_consistency

  private

  def tray_size_consistency
    if has_tray && tray_size_id.nil?
      errors.add(:tray_size_id, "doit être sélectionné si l'option barquette est active")
    end
  end
end
