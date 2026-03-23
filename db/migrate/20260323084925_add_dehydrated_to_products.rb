class AddDehydratedToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :dehydrated, :boolean, default: false, null: false
    add_column :products, :rehydration_coefficient, :decimal, precision: 6, scale: 2
  end
end
