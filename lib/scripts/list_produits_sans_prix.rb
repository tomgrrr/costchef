# encoding: utf-8

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")

produits = user.products
  .where("avg_price_per_kg IS NULL OR avg_price_per_kg = 0")
  .order(:name)

puts "TOTAL : #{produits.count} produits sans prix"
puts "---"
produits.each do |p|
  rc_count = RecipeComponent.where(component_type: "Product", component_id: p.id).count
  puts "#{p.id}\t#{p.name}\t#{p.base_unit}\t#{rc_count} recettes"
end
