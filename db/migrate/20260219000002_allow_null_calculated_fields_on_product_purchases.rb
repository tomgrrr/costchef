class AllowNullCalculatedFieldsOnProductPurchases < ActiveRecord::Migration[7.1]
  def change
    change_column_null :product_purchases, :package_quantity_kg, true
    change_column_null :product_purchases, :price_per_kg, true
    remove_check_constraint :product_purchases, name: "package_quantity_kg_positive"
    remove_check_constraint :product_purchases, name: "price_per_kg_positive"
  end
end
