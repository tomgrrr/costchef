# frozen_string_literal: true

class RestoreNotNullOnProductPurchases < ActiveRecord::Migration[7.1]
  def up
    # Remplacer les NULL existants par 0 avant d'appliquer la contrainte
    change_column_null :product_purchases, :package_quantity_kg, false, 0
    change_column_null :product_purchases, :price_per_kg, false, 0
  end

  def down
    change_column_null :product_purchases, :package_quantity_kg, true
    change_column_null :product_purchases, :price_per_kg, true
  end
end
