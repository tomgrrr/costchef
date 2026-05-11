class ChangeDefaultTvaRateToFivePointFive < ActiveRecord::Migration[7.1]
  def up
    change_column_default :recipes, :tva_rate, from: 10.0, to: 5.5
    Recipe.update_all(tva_rate: 5.5)
  end

  def down
    change_column_default :recipes, :tva_rate, from: 5.5, to: 10.0
    Recipe.update_all(tva_rate: 10.0)
  end
end
