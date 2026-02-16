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
class Product < ApplicationRecord
  belongs_to :user

  # Un produit a plusieurs achats. Si on détruit le produit, on détruit ses achats.
  has_many :product_purchases, dependent: :destroy

  # Utilisation dans les recettes (via polymorphisme)
  has_many :recipe_components, as: :component

  # Validations
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :base_unit, presence: true, inclusion: { in: %w[kg l piece] }

  # D14: Jamais nil, défaut 0, >= 0
  validates :avg_price_per_kg, numericality: { greater_than_or_equal_to: 0 }, presence: true

  # D6: Validation conditionnelle stricte pour les pièces
  validates :unit_weight_kg, presence: true, numericality: { greater_than: 0 }, if: :piece_unit?
  validates :unit_weight_kg, absence: true, unless: :piece_unit?

  # Protection suppression (Section 8.4)
  # Impossible de supprimer si utilisé dans une recette
  before_destroy :check_usage_in_recipes

  def piece_unit?
    base_unit == 'piece'
  end

  private

  def check_usage_in_recipes
    if recipe_components.exists?
      errors.add(:base, "Ce produit est utilisé dans #{recipe_components.count} recettes. Impossible de le supprimer.")
      throw(:abort)
    end
  end
end
