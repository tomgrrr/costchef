# encoding: utf-8
# Lot 3 — Conditionnements issus des factures fournisseurs
# Produits : moutarde, vinaigre balsamique, ketchup, foie gras (x2), ricard, jus d'orange

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")
abort "User introuvable" unless user

transgourmet    = user.suppliers.find(107)
ds_restauration = user.suppliers.find(108)
metro           = user.suppliers.find(105)
brendani        = user.suppliers.where("name ILIKE ?", "brendani").first_or_create!(name: "Brendani")

puts "Fournisseurs : Transgourmet=#{transgourmet.id}, DS=#{ds_restauration.id}, Metro=#{metro.id}, Brendani=#{brendani.id}"
puts ""

def add_cond(user, product_id, supplier, qty, unit, price)
  product = user.products.find_by(id: product_id)
  unless product
    puts "  ❌ Produit ID #{product_id} introuvable — skip"
    return
  end
  existing = product.product_purchases.find_by(supplier: supplier, package_quantity: qty, package_unit: unit)
  if existing
    puts "  ⚠️  #{product.name} — conditionnement #{qty}#{unit} #{supplier.name} déjà existant — skip"
    return
  end
  ProductPurchase.create!(product: product, supplier: supplier, package_quantity: qty, package_unit: unit, package_price: price)
  Products::AvgPriceRecalculator.call(product)
  puts "  ✅ #{product.name} | #{qty}#{unit} @ #{price}€ | #{supplier.name} → avg #{product.reload.avg_price_per_kg&.round(3)}€/kg"
end

puts "=== VÉRIFICATION BASE_UNITS ==="
[1091, 1088, 1213, 1079, 1116].each do |pid|
  p = user.products.find_by(id: pid)
  puts "  ID #{pid} | #{p&.name} | base_unit: #{p&.base_unit} | allowed: #{Units.allowed_for(p&.base_unit).join(', ')}"
end
puts ""

puts "=== IMPORT ==="
# 1091 déjà importé (vinaigre balsamique) — la garde-fou dans add_cond gère le skip
add_cond(user, 1091, transgourmet,    2,   "l",  10.10)  # Vinaigre balsamique (base_unit: l)
add_cond(user, 1088, brendani,        1,   "kg",  4.65)  # Ketchup Colona (base_unit: kg, 1L ≈ 1kg)
add_cond(user, 1213, ds_restauration, 1,   "kg", 59.00)  # Foie gras 1kg
add_cond(user, 1213, ds_restauration, 500, "g",  33.00)  # Foie gras 500g
add_cond(user, 1079, metro,           1,   "l",  14.03)  # Ricard (base_unit: l)
add_cond(user, 1116, metro,           1,   "l",   1.78)  # Jus d'orange pur jus (base_unit: l)

puts ""
puts "Done."
