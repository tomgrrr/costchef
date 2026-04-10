# encoding: utf-8

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")

old_p  = user.products.find_by(id: 1229) # sauce crustace
new_p  = user.products.where("name ILIKE ?", "sauce aux crustacés").first

puts "Source : ID #{old_p&.id} — #{old_p&.name} (#{old_p&.product_purchases&.count} cond)"
puts "Cible  : ID #{new_p&.id} — #{new_p&.name} (#{new_p&.product_purchases&.count} cond, #{new_p&.avg_price_per_kg}€/kg)"

unless old_p && new_p
  puts "ERREUR : produit introuvable"
  exit
end

rc_list = RecipeComponent.where(component_type: "Product", component_id: old_p.id)
puts "#{rc_list.count} recipe_component(s) à migrer"

rc_list.each do |rc|
  existing = RecipeComponent.find_by(parent_recipe_id: rc.parent_recipe_id, component_type: "Product", component_id: new_p.id)
  if existing
    existing.update!(quantity_kg: existing.quantity_kg + rc.quantity_kg)
    rc.destroy!
    puts "  Doublon fusionné (recette #{rc.parent_recipe_id})"
  else
    rc.update!(component_id: new_p.id)
    recipe = Recipe.find(rc.parent_recipe_id)
    puts "  → rebranché sur #{new_p.name} (recette #{recipe.name})"
  end
end

old_p.delete
puts "Supprimé : ID #{old_p.id} — #{old_p.name}"

puts "Recalcul..."
RecipeComponent.where(component_type: "Product", component_id: new_p.id).pluck(:parent_recipe_id).uniq.each do |rid|
  Recipes::Recalculator.call(Recipe.find(rid))
rescue => e
  puts "  ✗ #{rid} : #{e.message}"
end

puts "Done."
