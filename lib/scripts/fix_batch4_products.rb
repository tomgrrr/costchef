# encoding: utf-8
# frozen_string_literal: true
# Corrige les produits mal créés lors du batch4 :
# 1. Supprime les doublons "Jaune d'oeuf" (doit utiliser "Jaune" existant)
# 2. Rerattache Sauce quiche au bon produit "Jaune"

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

jaune_correct  = user.products.find_by!("name = ?", "Jaune")
puts "Produit correct : #{jaune_correct.name} — #{jaune_correct.avg_price_per_kg.round(2)} EUR/kg"

ActiveRecord::Base.transaction do

  # 1. Rerattacher les RecipeComponents qui pointent vers "Jaune d'oeuf" → "Jaune"
  faux_jauneIds = user.products.where("name = ?", "Jaune d'oeuf").pluck(:id)

  if faux_jauneIds.any?
    comps = RecipeComponent.where(component_type: "Product", component_id: faux_jauneIds)
    puts "\nRecipeComponents à rerattacher : #{comps.count}"
    comps.each do |rc|
      rc.update!(component_id: jaune_correct.id)
      puts "  [FIXE] #{rc.parent_recipe.name} → Jaune"
    end

    # 2. Supprimer les faux produits "Jaune d'oeuf"
    user.products.where("name = ?", "Jaune d'oeuf").destroy_all
    puts "\n[SUPPRIME] Tous les produits 'Jaune d''oeuf' (#{faux_jauneIds.count})"
  else
    puts "\n[OK] Aucun produit 'Jaune d''oeuf' a supprimer"
  end

  # 3. Recalculer la Sauce quiche
  sauce_quiche = user.recipes.find_by!("LOWER(name) = ?", "sauce quiche")
  Recipes::Recalculator.call(sauce_quiche)
  sauce_quiche.reload
  puts "\n[RECALCUL] Sauce quiche → #{sauce_quiche.cached_cost_per_kg.round(2)} EUR/kg"
  puts "Composants :"
  sauce_quiche.recipe_components.includes(:component).each do |rc|
    puts "  #{rc.component.name} : #{rc.quantity_kg} kg"
  end

end
