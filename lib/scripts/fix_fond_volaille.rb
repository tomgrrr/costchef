# encoding: utf-8

product = Product.find(1049)
puts "Produit : #{product.name} | base_unit: #{product.base_unit}"
puts ""
puts "Conditionnements :"
product.product_purchases.each do |pp|
  puts "  ID #{pp.id} | fournisseur: #{pp.supplier} | qty: #{pp.package_quantity} #{pp.package_unit} | prix: #{pp.package_price}€"
end
puts ""

# Corriger les conditionnements avec package_unit "piece" (invalide pour un produit kg)
invalid = product.product_purchases.where(package_unit: "piece")
puts "Conditionnements invalides (piece sur produit kg) : #{invalid.count}"

invalid.each do |pp|
  puts "  Correction ID #{pp.id} : piece → kg"
  pp.update_columns(package_unit: "kg")
end

puts ""
puts "Recalcul du produit..."
Products::AvgPriceRecalculator.call(product)
puts "avg_price après : #{product.reload.avg_price}"

puts ""
puts "Recalcul des recettes qui utilisent ce produit..."
product.recipe_components.each do |rc|
  recipe = rc.parent_recipe
  Recipes::Recalculator.call(recipe)
  puts "  #{recipe.name} → coût : #{recipe.reload.total_cost}"
end

puts ""
puts "Done."
