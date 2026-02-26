# frozen_string_literal: true

module Recipes
  class Duplicator
    def self.call(recipe)
      new(recipe).call
    end

    def initialize(recipe)
      @recipe = recipe
    end

    def call
      new_recipe = @recipe.dup
      new_recipe.name = "#{@recipe.name} (copie)"
      copy_components(new_recipe)
      new_recipe
    end

    private

    def copy_components(new_recipe)
      @recipe.recipe_components.each do |rc|
        new_recipe.recipe_components.build(
          rc.attributes.except("id", "parent_recipe_id", "created_at", "updated_at")
        )
      end
    end
  end
end
