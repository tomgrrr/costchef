class RestoreProductsUniqueIndex < ActiveRecord::Migration[7.1]
  def change
    remove_index :products, :name, if_exists: true
    add_index :products, [:user_id, :name], unique: true
    # Conserver l'index simple user_id (PRD Section 6.11 — CRITIQUE pour l'isolation des données)
    add_index :products, :user_id, if_not_exists: true
  end
end
