class AddUnitWeightKgPieceConsistencyCheckToProducts < ActiveRecord::Migration[7.1]
  def up
    add_check_constraint :products,
      "(base_unit = 'piece' AND unit_weight_kg IS NOT NULL AND unit_weight_kg > 0) OR (base_unit != 'piece' AND unit_weight_kg IS NULL)",
      name: "unit_weight_kg_piece_consistency"
  end

  def down
    remove_check_constraint :products, name: "unit_weight_kg_piece_consistency"
  end
end
