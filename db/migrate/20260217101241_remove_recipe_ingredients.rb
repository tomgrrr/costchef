# frozen_string_literal: true

# Cette migration supprime l'ancienne table `recipe_ingredients` qui ne gérait que
# les liens directs entre Recettes et Produits.
#
# Conformément au PRD v1.5 (Section 6.7), elle est remplacée par la table
# `recipe_components` qui utilise le polymorphisme pour gérer à la fois les
# Produits et les Sous-Recettes comme composants d'une recette parente.
class RemoveRecipeIngredients < ActiveRecord::Migration[7.1]
  def change
    # On précise les colonnes pour permettre un rollback automatique si besoin
    drop_table :recipe_ingredients do |t|
      t.bigint 'recipe_id', null: false
      t.bigint 'product_id', null: false
      t.decimal 'quantity', precision: 10, scale: 3, null: false
      t.timestamps
    end
  end
end
