# frozen_string_literal: true

class Product < ApplicationRecord
  # Relations
  belongs_to :user
  has_many :recipe_ingredients, dependent: :restrict_with_error
  has_many :recipes, through: :recipe_ingredients

  # Validations
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :price, presence: true, numericality: { greater_than: 0 }

  # Callbacks
  after_update :recalculate_affected_recipes, if: :saved_change_to_price?

  private

  def recalculate_affected_recipes
    recipes.find_each(&:recalculate_costs)
  end
end
