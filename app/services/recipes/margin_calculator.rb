# frozen_string_literal: true

module Recipes
  # Margin on raw materials implied by the user's coefficient. The selling
  # price before tray is cost × coefficient, so the margin is
  # cost × (coefficient − 1) per kg, i.e. (1 − 1 / coefficient) of the price.
  # Read-only. nil when the recipe has no cost yet or when the coefficient
  # doesn't cover the cost (≤ 1).
  class MarginCalculator
    def self.call(recipe)
      new(recipe).call
    end

    def initialize(recipe)
      raise ArgumentError, 'recipe is required' if recipe.nil?

      @recipe = recipe
    end

    def call
      cost = @recipe.cached_cost_per_kg.to_d
      coefficient = @recipe.user.markup_coefficient.to_d
      return nil unless cost.positive? && coefficient > 1

      { per_kg: cost * (coefficient - 1), rate: (1 - (1 / coefficient)) * 100 }
    end
  end
end
