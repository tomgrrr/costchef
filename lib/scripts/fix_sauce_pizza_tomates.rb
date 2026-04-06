# encoding: utf-8
# frozen_string_literal: true
# Corrige Sauce pizza : Tomates 4kg → 16.8kg (4 boites × 4.2kg)
# Le batch2 avait traité "4 unités" comme 4 kg au lieu du poids réel

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

ActiveRecord::Base.transaction do

  sauce = user.recipes.find_by!("LOWER(name) = ?", "sauce pizza")
  puts "Recette : #{sauce.name}"

  tomates = user.products.find_by!("name ILIKE ?", "%Tomate%")
  puts "Produit trouvé : #{tomates.name}"

  rc = sauce.recipe_components.find_by(component_type: "Product", component_id: tomates.id)
  raise "Tomates introuvable dans Sauce pizza" unless rc

  puts "  Avant : Tomates #{rc.quantity_kg} kg"
  rc.update!(quantity_kg: 16.8)
  puts "  [FIX] Tomates 4kg → 16.8kg (4 boites × 4.2kg)"

  Recipes::Recalculator.call(sauce)
  sauce.reload
  puts "  → #{sauce.cached_cost_per_kg.round(2)} EUR/kg | #{sauce.cached_total_weight.round(2)} kg total"

  # Recalculer les recettes qui utilisent Sauce pizza (Sauce spaghetti, Sauce ris de veau)
  impactes = RecipeComponent
    .where(component_type: "Recipe", component_id: sauce.id)
    .map(&:parent_recipe).uniq.compact

  if impactes.any?
    puts "\n  Recalcul recettes impactées :"
    impactes.each do |r|
      Recipes::Recalculator.call(r)
      r.reload
      puts "    #{r.name} → #{r.cached_cost_per_kg.round(2)} EUR/kg"
    end
  end

end
