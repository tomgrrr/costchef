# encoding: utf-8

product = Product.find(1049)
puts "Produit : #{product.name} | avg_price_per_kg: #{product.avg_price_per_kg}"
puts ""

puts "Recalcul des recettes qui utilisent ce produit..."
recipe_ids = product.recipe_components.pluck(:parent_recipe_id).uniq
puts "#{recipe_ids.count} recettes trouvées"

recipe_ids.each do |rid|
  recipe = Recipe.find(rid)
  Recipes::Recalculator.call(recipe)
  puts "  ✓ #{recipe.name} → #{recipe.reload.total_cost}€"
rescue => e
  puts "  ✗ Recipe #{rid} : #{e.message}"
end

puts ""
puts "Done."
