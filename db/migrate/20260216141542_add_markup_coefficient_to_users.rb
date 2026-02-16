class AddMarkupCoefficientToUsers < ActiveRecord::Migration[7.1]
  def change
     add_column :users, :markup_coefficient, :decimal, precision: 5, scale: 2, null: false, default: 1.0
  end
end
