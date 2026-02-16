
class CreateProductPurchases < ActiveRecord::Migration[7.1]
  def change
    create_table :product_purchases do |t|
      t.references :product, null: false, foreign_key: { on_delete: :cascade }
      t.references :supplier, null: false, foreign_key: { on_delete: :restrict }
      t.decimal :package_quantity, precision: 10, scale: 3, null: false
      t.string :package_unit, null: false, default: 'kg'
      t.decimal :package_quantity_kg, precision: 10, scale: 3, null: false
      t.decimal :package_price, precision: 10, scale: 2, null: false
      t.decimal :price_per_kg, precision: 10, scale: 4, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    # Index critiques
    add_index :product_purchases, [:product_id, :active], name: 'index_product_purchases_on_product_and_active'
    add_index :product_purchases, [:product_id, :supplier_id]

    # Contraintes CHECK
    add_check_constraint :product_purchases, "package_quantity > 0", name: "package_quantity_positive"
    add_check_constraint :product_purchases, "package_quantity_kg > 0", name: "package_quantity_kg_positive"
    add_check_constraint :product_purchases, "package_price >= 0", name: "package_price_positive"
    add_check_constraint :product_purchases, "price_per_kg >= 0", name: "price_per_kg_positive"
  end
end
