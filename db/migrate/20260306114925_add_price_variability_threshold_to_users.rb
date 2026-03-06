class AddPriceVariabilityThresholdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :price_variability_threshold, :decimal, precision: 5, scale: 2, null: false, default: 10.0
  end
end
