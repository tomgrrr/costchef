# frozen_string_literal: true

class RecipeIngredient < ApplicationRecord
  # Relations
  belongs_to :recipe
  belongs_to :product

  # Validations
  validates :quantity, presence: true, numericality: { greater_than: 0 }

  # Callbacks
  after_save :trigger_recipe_recalculation
  after_destroy :trigger_recipe_recalculation

  private

  def trigger_recipe_recalculation
    recipe.recalculate_costs
  end
end
