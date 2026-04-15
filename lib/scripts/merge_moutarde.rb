# encoding: utf-8
# Migre les RecipeComponents de "Moutarde" (ID 1092) vers "Moutarde dijon" (ID 1184)
# puis supprime le produit source.

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")
abort "User introuvable" unless user

source = user.products.find(1092)  # Moutarde — sans conditionnement, utilisé dans recettes
target = user.products.find(1184)  # Moutarde dijon — avec conditionnements, à conserver

puts "Source : ID #{source.id} — #{source.name} (#{source.product_purchases.count} cond, #{RecipeComponent.where(component_type: 'Product', component_id: source.id).count} RC)"
puts "Cible  : ID #{target.id} — #{target.name} (#{target.product_purchases.count} cond, #{RecipeComponent.where(component_type: 'Product', component_id: target.id).count} RC)"
puts ""

rc_list = RecipeComponent.where(component_type: "Product", component_id: source.id)
puts "=== MIGRATION #{rc_list.count} RecipeComponents ==="

rc_list.each do |rc|
  existing = RecipeComponent.find_by(parent_recipe_id: rc.parent_recipe_id, component_type: "Product", component_id: target.id)
  if existing
    existing.update!(quantity_kg: existing.quantity_kg + rc.quantity_kg)
    rc.destroy!
    puts "  Recette #{rc.parent_recipe_id} — fusionné (quantités additionnées)"
  else
    rc.update!(component_id: target.id)
    puts "  Recette #{rc.parent_recipe_id} — rebranché"
  end
end

puts ""
puts "=== SUPPRESSION source ==="
source.delete
puts "  Supprimé : #{source.name} (ID #{source.id})"

puts ""
puts "=== RECALCUL recettes affectées ==="
recipe_ids = rc_list.map(&:parent_recipe_id).uniq
recipe_ids.each do |rid|
  r = Recipe.find_by(id: rid)
  next unless r
  Recipes::Recalculator.call(r)
  puts "  Recette #{r.id} — #{r.name} recalculée"
end

puts ""
puts "Done."
