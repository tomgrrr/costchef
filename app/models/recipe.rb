# frozen_string_literal: true

class Recipe < ApplicationRecord
  # Relations
  belongs_to :user
  has_many :recipe_ingredients, dependent: :destroy
  has_many :products, through: :recipe_ingredients

  # Validations
  validates :name, presence: true, uniqueness: { scope: :user_id }

  # Recalcule les coûts cached de la recette
  def recalculate_costs
    total_cost = recipe_ingredients.joins(:product)
                                   .sum("recipe_ingredients.quantity * products.price")
    total_weight = recipe_ingredients.sum(:quantity)

    cost_per_kg = total_weight.positive? ? (total_cost / total_weight).round(2) : 0

    update_columns(
      cached_total_cost: total_cost.round(2),
      cached_total_weight: total_weight.round(3),
      cached_cost_per_kg: cost_per_kg
    )
  end
end
