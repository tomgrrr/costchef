# encoding: utf-8
# Recalcul complet des prix et coûts pour Lassalas
# Robuste : saute les produits avec conditionnements invalides

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")

puts "Recalcul prix produits..."
errors = []

user.products.find_each do |product|
  begin
    Products::AvgPriceRecalculator.call(product)
  rescue => e
    errors << "Produit #{product.id} (#{product.name}) : #{e.message.truncate(80)}"
  end
end

puts "Recalcul coûts recettes..."

user.recipes.find_each do |recipe|
  begin
    Recipes::Recalculator.call(recipe)
  rescue => e
    errors << "Recette #{recipe.id} (#{recipe.name}) : #{e.message.truncate(80)}"
  end
end

puts ""
if errors.any?
  puts "#{errors.count} erreur(s) ignoree(s) :"
  errors.each { |e| puts "  - #{e}" }
else
  puts "Aucune erreur"
end

puts "Recalcul termine."
