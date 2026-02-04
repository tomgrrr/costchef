# frozen_string_literal: true

class CreateRecipeIngredients < ActiveRecord::Migration[7.1]
  def change
    create_table :recipe_ingredients do |t|
      t.references :recipe, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.decimal :quantity, precision: 10, scale: 3, null: false

      t.timestamps
    end

    add_index :recipe_ingredients, [:recipe_id, :product_id]

    # Contrainte CHECK pour quantité > 0
    execute <<-SQL
      ALTER TABLE recipe_ingredients ADD CONSTRAINT quantity_positive CHECK (quantity > 0);
    SQL
  end
end
