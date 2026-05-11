class AddTvaRateToRecipes < ActiveRecord::Migration[7.1]
  def change
    add_column :recipes, :tva_rate, :decimal, precision: 4, scale: 2, default: 10.0, null: false
  end
end
