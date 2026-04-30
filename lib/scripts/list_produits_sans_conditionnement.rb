# encoding: utf-8
# Liste tous les produits sans aucun conditionnement (product_purchases vide)
# Lecture seule — aucune modification

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")
abort "User introuvable" unless user

produits = user.products
  .left_joins(:product_purchases)
  .where(product_purchases: { id: nil })
  .order(:name)

puts "=== PRODUITS SANS CONDITIONNEMENT — LASSALAS (#{produits.count} total) ==="
puts ""
puts "%-6s | %-10s | %s" % ["ID", "base_unit", "Nom"]
puts "-" * 70

produits.each do |p|
  puts "%-6s | %-10s | %s" % [p.id, p.base_unit, p.name]
end

puts ""
puts "TOTAL : #{produits.count} produit(s) sans conditionnement"
