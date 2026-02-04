# frozen_string_literal: true

class AddOnDeleteToForeignKeys < ActiveRecord::Migration[7.1]
  def change
    # Supprimer les anciennes foreign keys
    remove_foreign_key :products, :users
    remove_foreign_key :recipes, :users
    remove_foreign_key :recipe_ingredients, :recipes
    remove_foreign_key :recipe_ingredients, :products

    # Recréer avec le bon comportement ON DELETE
    add_foreign_key :products, :users, on_delete: :cascade
    add_foreign_key :recipes, :users, on_delete: :cascade
    add_foreign_key :recipe_ingredients, :recipes, on_delete: :cascade
    add_foreign_key :recipe_ingredients, :products, on_delete: :restrict
  end
end
