
class DropRecipeIngredients < ActiveRecord::Migration[7.1]
  def up
    drop_table :recipe_ingredients
  end

  def down
    # Recréer la table si rollback nécessaire
    create_table :recipe_ingredients do |t|
      t.references :recipe, null: false, foreign_key: { on_delete: :cascade }
      t.references :product, null: false, foreign_key: { on_delete: :restrict }
      t.decimal :quantity, precision: 10, scale: 3, null: false

      t.timestamps
    end

    add_index :recipe_ingredients, [:recipe_id, :product_id]
    add_check_constraint :recipe_ingredients, "quantity > 0", name: "quantity_positive"
  end
end
