# frozen_string_literal: true

class AddQuantityUnitToRecipeComponents < ActiveRecord::Migration[7.1]
  # quantity_unit est conservé uniquement pour l'affichage UI. La valeur stockée dans
  # quantity_kg est toujours en kg (PRD D1). La conversion est effectuée avant save
  # via Units::Converter dans RecipeComponentsController.
  def change
    add_column :recipe_components, :quantity_unit, :string, null: false, default: 'kg'

    reversible do |dir|
      dir.up do
        execute <<~SQL
          ALTER TABLE recipe_components
          ADD CONSTRAINT valid_quantity_unit
          CHECK (quantity_unit IN ('kg', 'g', 'l', 'cl', 'ml', 'piece'))
        SQL
      end

      dir.down do
        execute <<~SQL
          ALTER TABLE recipe_components
          DROP CONSTRAINT valid_quantity_unit
        SQL
      end
    end
  end
end
