class AddSoldByUnitToRecipes < ActiveRecord::Migration[7.1]
  def change
    add_column :recipes, :sold_by_unit, :boolean, default: false, null: false
    add_column :recipes, :unit_reference_weight_kg, :decimal, precision: 10, scale: 3
  end
end
