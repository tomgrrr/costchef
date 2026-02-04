# frozen_string_literal: true

class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :price, precision: 8, scale: 2, null: false
      t.string :unit

      t.timestamps
    end

    add_index :products, :name
    add_index :products, [:user_id, :name], unique: true

    # Contrainte CHECK pour prix > 0
    execute <<-SQL
      ALTER TABLE products ADD CONSTRAINT price_positive CHECK (price > 0);
    SQL
  end
end
