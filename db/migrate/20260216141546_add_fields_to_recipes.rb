
class AddFieldsToRecipes < ActiveRecord::Migration[7.1]
  def change
    add_column :recipes, :sellable_as_component, :boolean, null: false, default: false
    add_column :recipes, :cooking_loss_percentage, :decimal, precision: 5, scale: 2, default: 0
    add_column :recipes, :has_tray, :boolean, null: false, default: false
    add_column :recipes, :tray_size_id, :bigint
    add_column :recipes, :cached_raw_weight, :decimal, precision: 10, scale: 3

    # Foreign key vers tray_sizes (sera créée à la migration suivante)
    # On l'ajoutera dans une migration ultérieure pour éviter les problèmes d'ordre

    # Contraintes CHECK
    add_check_constraint :recipes, "cooking_loss_percentage >= 0 AND cooking_loss_percentage <= 100", name: "cooking_loss_percentage_range"
    add_check_constraint :recipes, "cached_raw_weight IS NULL OR cached_raw_weight >= 0", name: "cached_raw_weight_positive"
  end
end
