# encoding: utf-8
# frozen_string_literal: true
# Corrige 3 PP mal placés détectés par audit_global :
#   - PP#3831 → Persillade (était dans Persil, 182€/kg = persillade Ducros)
#   - PP#3865 → Épeautre bio (était dans Farine T55, 9.73€/kg = petit épeautre Colin)
#   - PP#3345 → Compote pomme (était dans Pomme, 12.16€/kg = compote ABP)

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

def move_pp(pp_id, target_name, user)
  pp = ProductPurchase.find_by(id: pp_id)
  unless pp
    puts "  ⚠️  PP##{pp_id} introuvable"
    return
  end

  src_name = pp.product.name
  target = user.products.find_by("name = ?", target_name) ||
           user.products.find_by("name ILIKE ?", target_name)

  unless target
    puts "  ⚠️  Produit cible '#{target_name}' introuvable"
    return
  end

  pp.update!(product: target)
  Products::AvgPriceRecalculator.call(target)
  target.reload
  puts "  ✅ PP##{pp_id} : '#{src_name}' → '#{target.name}' | avg → #{target.avg_price_per_kg.to_f.round(3)} €/kg"

  # Recalcul produit source
  src = user.products.find_by(id: pp.product_id) rescue nil
  if src
    Products::AvgPriceRecalculator.call(src)
    src.reload
    puts "     Source '#{src.name}' avg recalculé → #{src.avg_price_per_kg.to_f.round(3)} €/kg"
  end
end

puts "=== FIX PP MAL PLACÉS (round 2) ==="

puts "\n1. PP#3831 → Persillade"
move_pp(3831, "Persillade", user)

puts "\n2. PP#3865 → Épeautre bio"
epeautre = user.products.where("name ILIKE ?", "%peautre%").first
unless epeautre
  epeautre = user.products.create!(name: "Épeautre bio")
  puts "  ✨ Produit 'Épeautre bio' créé (ID #{epeautre.id})"
end
pp3865 = ProductPurchase.find_by(id: 3865)
if pp3865
  src_name = pp3865.product.name
  pp3865.update!(product: epeautre)
  Products::AvgPriceRecalculator.call(epeautre)
  epeautre.reload
  puts "  ✅ PP#3865 : '#{src_name}' → '#{epeautre.name}' | avg → #{epeautre.avg_price_per_kg.to_f.round(3)} €/kg"
else
  puts "  ⚠️  PP#3865 introuvable"
end

puts "\n3. PP#3345 → Compote pomme"
compote = user.products.where("name ILIKE ?", "%compote%").first
unless compote
  compote = user.products.create!(name: "Compote pomme")
  puts "  ✨ Produit 'Compote pomme' créé (ID #{compote.id})"
end
move_pp(3345, compote.name, user)

puts "\n=== TERMINÉ ==="
