
class ModifyProductsTable < ActiveRecord::Migration[7.1]
  def change
    # 1) Remove legacy constraint first (safe)
    if check_constraint_exists?(:products, name: "price_positive")
      remove_check_constraint :products, name: "price_positive"
    end

    # 2) Remove legacy columns (safe)
    remove_column :products, :price, :decimal if column_exists?(:products, :price)
    remove_column :products, :unit, :string   if column_exists?(:products, :unit)

    # 3) Add PRD columns
    add_column :products, :base_unit, :string, null: false, default: "kg" unless column_exists?(:products, :base_unit)
    add_column :products, :unit_weight_kg, :decimal, precision: 10, scale: 4 unless column_exists?(:products, :unit_weight_kg)
    add_column :products, :avg_price_per_kg, :decimal, precision: 10, scale: 4, null: false, default: 0 unless column_exists?(:products, :avg_price_per_kg)

    # 4) Remove legacy index by name (safe)
    if index_name_exists?(:products, "index_products_on_user_id_and_name")
      remove_index :products, name: "index_products_on_user_id_and_name"
    end
  end
end
