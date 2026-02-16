
class CreateRecipeComponents < ActiveRecord::Migration[7.1]
  def change
    create_table :recipe_components do |t|
      t.bigint :parent_recipe_id, null: false
      t.string :component_type, null: false
      t.bigint :component_id, null: false
      t.decimal :quantity_kg, precision: 10, scale: 3, null: false

      t.timestamps
    end

    # Foreign key
    add_foreign_key :recipe_components, :recipes, column: :parent_recipe_id, on_delete: :cascade

    # Index critiques
    add_index :recipe_components, :parent_recipe_id
    add_index :recipe_components, [:component_type, :component_id]
    add_index :recipe_components, [:parent_recipe_id, :component_type, :component_id],
              unique: true, name: 'index_recipe_components_uniqueness'

    # Contraintes CHECK
    add_check_constraint :recipe_components, "quantity_kg > 0", name: "quantity_kg_positive"
    add_check_constraint :recipe_components, "component_type IN ('Product', 'Recipe')", name: "valid_component_type"
  end
end
