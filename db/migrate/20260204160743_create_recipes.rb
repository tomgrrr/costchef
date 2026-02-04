# frozen_string_literal: true

class CreateRecipes < ActiveRecord::Migration[7.1]
  def change
    create_table :recipes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.decimal :cached_total_cost, precision: 10, scale: 2
      t.decimal :cached_total_weight, precision: 10, scale: 3
      t.decimal :cached_cost_per_kg, precision: 10, scale: 2

      t.timestamps
    end

    add_index :recipes, :name
    add_index :recipes, [:user_id, :name], unique: true
    add_index :recipes, :cached_cost_per_kg
  end
end
