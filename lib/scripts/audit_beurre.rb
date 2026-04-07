# encoding: utf-8
user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

# Tous les produits contenant "beurre"
beurres = user.products.where("name ILIKE ?", "%beurre%").order(:name)
puts "=== Produits 'beurre' dans la base ==="
beurres.each do |b|
  puts "  ID #{b.id} | #{b.name} | #{b.avg_price_per_kg.to_f.round(2)} €/kg"
end

# Pour chaque produit beurre, les recettes qui l'utilisent
puts "\n=== Recettes par produit beurre ==="
beurres.each do |b|
  recipes = RecipeComponent.where(component_type: "Product", component_id: b.id)
                           .includes(:parent_recipe)
                           .map { |rc| rc.parent_recipe.name }
  next if recipes.empty?
  puts "\n#{b.name} (ID #{b.id}, #{b.avg_price_per_kg.to_f.round(2)} €/kg) :"
  recipes.each { |r| puts "  - #{r}" }
end
