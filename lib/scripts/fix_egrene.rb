# encoding: utf-8
# frozen_string_literal: true
# Corrige le produit "Égrainés de boeuf" créé à tort par batch4 :
# → Rerattache la Bolognaise au vrai produit "Egrene" (11.77 EUR/kg)

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

egrene_correct = user.products.find_by!("name ILIKE ?", "%grene%")
puts "Produit correct : #{egrene_correct.name} — #{egrene_correct.avg_price_per_kg.round(2)} EUR/kg — #{egrene_correct.product_purchases.count} condits"

ActiveRecord::Base.transaction do

  faux_ids = user.products.where("name ILIKE ?", "%grains%").pluck(:id)

  if faux_ids.any?
    comps = RecipeComponent.where(component_type: "Product", component_id: faux_ids)
    puts "\nRecipeComponents à rerattacher : #{comps.count}"
    comps.each do |rc|
      rc.update!(component_id: egrene_correct.id)
      puts "  [FIXE] #{rc.parent_recipe.name} → #{egrene_correct.name}"
    end

    user.products.where("name ILIKE ?", "%grains%").destroy_all
    puts "[SUPPRIME] Produit(s) 'Égrainés de boeuf' (#{faux_ids.count})"
  else
    puts "[OK] Aucun faux produit à supprimer"
  end

  bolognaise = user.recipes.find_by!("LOWER(name) LIKE ?", "%bolognaise%")
  Recipes::Recalculator.call(bolognaise)
  bolognaise.reload
  puts "\n[RECALCUL] #{bolognaise.name} → #{bolognaise.cached_cost_per_kg.round(2)} EUR/kg"

end
