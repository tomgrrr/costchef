# frozen_string_literal: true

module Recipes
  # Splits a recipe's raw-material cost by ingredient, for the "Où part le
  # coût" chart: the `top` most expensive lines, then the rest grouped as
  # "Autres". Read-only; returns [] when the recipe has no cost yet.
  #
  #   Recipes::CostBreakdown.call(recipe)
  #   # => [{ name: "Canard", cost: 63.21, share: 78.2 }, ..., { name: "Autres", ... }]
  class CostBreakdown
    OTHERS_LABEL = 'Autres'

    def self.call(recipe, top: 4)
      new(recipe, top).call
    end

    def initialize(recipe, top)
      raise ArgumentError, 'recipe is required' if recipe.nil?

      @recipe = recipe
      @top = top
    end

    def call
      lines = costed_lines
      total = lines.sum { |line| line[:cost] }
      return [] unless total.positive?

      grouped(lines).map { |line| line.merge(share: (line[:cost] / total * 100).round(1)) }
    end

    private

    def costed_lines
      @recipe.recipe_components
             .map { |rc| { name: rc.component.name, cost: rc.line_cost.to_d } }
             .select { |line| line[:cost].positive? }
             .sort_by { |line| -line[:cost] }
    end

    def grouped(lines)
      head = lines.first(@top)
      rest = lines.drop(@top)
      return head if rest.empty?

      head + [{ name: OTHERS_LABEL, cost: rest.sum { |line| line[:cost] } }]
    end
  end
end
