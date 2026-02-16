class MigrateRecipeIngredientsToComponents < ActiveRecord::Migration[7.1]
  def up
    # 1) Consolider les doublons (PRD impose unicité)
    # On insère en groupant par recipe_id/product_id et en sommant quantity.
    execute <<~SQL
      INSERT INTO recipe_components (parent_recipe_id, component_type, component_id, quantity_kg, created_at, updated_at)
      SELECT
        recipe_id AS parent_recipe_id,
        'Product' AS component_type,
        product_id AS component_id,
        SUM(quantity) AS quantity_kg,
        MIN(created_at) AS created_at,
        MAX(updated_at) AS updated_at
      FROM recipe_ingredients
      GROUP BY recipe_id, product_id;
    SQL
  end

  def down
    # On supprime uniquement ce qui vient des anciens recipe_ingredients
    execute <<~SQL
      DELETE FROM recipe_components
      WHERE component_type = 'Product';
    SQL
  end
end
