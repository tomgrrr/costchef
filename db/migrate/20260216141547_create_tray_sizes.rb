
class CreateTraySizes < ActiveRecord::Migration[7.1]
  def change
    create_table :tray_sizes do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.decimal :price, precision: 8, scale: 2, null: false

      t.timestamps
    end

    add_index :tray_sizes, [:user_id, :name], unique: true
    add_check_constraint :tray_sizes, "price >= 0", name: "tray_price_positive"

    # Ajouter maintenant la foreign key de recipes vers tray_sizes
    add_foreign_key :recipes, :tray_sizes, on_delete: :nullify
    add_index :recipes, :tray_size_id
  end
end
