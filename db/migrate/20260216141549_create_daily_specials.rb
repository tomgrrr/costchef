
class CreateDailySpecials < ActiveRecord::Migration[7.1]
  def change
    create_table :daily_specials do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :category, null: false
      t.date :entry_date, null: false
      t.string :item_name, null: false
      t.decimal :cost_per_kg, precision: 10, scale: 2, null: false

      t.timestamps
    end

    # Index
    add_index :daily_specials, [:user_id, :category]
    add_index :daily_specials, [:user_id, :entry_date]

    # Contraintes CHECK
    add_check_constraint :daily_specials, "category IN ('meat', 'fish', 'side')", name: "valid_category"
    add_check_constraint :daily_specials, "cost_per_kg > 0", name: "cost_per_kg_positive"
  end
end
