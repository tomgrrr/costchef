# encoding: utf-8

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")

puts "=== POIREAUX ==="

cible  = user.products.where("name ILIKE ?", "poireaux").where.not("name ILIKE ?", "poireaux %").first
source = user.products.where("name ILIKE ?", "poireaux coup%").first

if source.nil?
  puts "Produit 'Poireaux coupés' introuvable — vérifier le nom exact"
  exit
end

puts "Source : ID #{source.id} — #{source.name} (#{source.product_purchases.count} conditionnements)"
puts "Cible  : ID #{cible.id} — #{cible.name} (#{cible.product_purchases.count} conditionnements, #{RecipeComponent.where(component_type: 'Product', component_id: cible.id).count} recettes)"

source.product_purchases.each do |pp|
  new_pp = pp.dup
  new_pp.product = cible
  new_pp.save!
  puts "  Conditionnement migré : #{pp.package_quantity} #{pp.package_unit} | #{pp.package_price}€ (#{pp.supplier&.name})"
end

Products::AvgPriceRecalculator.call(cible)
puts "avg_price_per_kg Poireaux : #{cible.reload.avg_price_per_kg}€/kg"

source.delete
puts "Supprimé : ID #{source.id} — #{source.name}"

puts "Recalcul des 14 recettes..."
RecipeComponent.where(component_type: "Product", component_id: cible.id).pluck(:parent_recipe_id).uniq.each do |rid|
  recipe = Recipe.find(rid)
  Recipes::Recalculator.call(recipe)
  puts "  ✓ #{recipe.name}"
rescue => e
  puts "  ✗ #{rid} : #{e.message}"
end

puts ""
puts "Done."
