# encoding: utf-8
# frozen_string_literal: true
# Déplace les ProductPurchases vers le bon produit (conditionnements mal classés)

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

def move_pp(pp_id, target_name, user)
  pp = ProductPurchase.find(pp_id)
  target = user.products.where("name ILIKE ?", target_name).first
  unless target
    puts "  ❌ Produit cible introuvable : #{target_name}"
    return
  end
  source_name = pp.product.name
  pp.update!(product: target)
  puts "  ✅ PP##{pp_id} : #{source_name} → #{target.name}"
  # Recalculer avg_price des deux produits
  Products::AvgPriceRecalculator.call(pp.product) rescue nil
  Products::AvgPriceRecalculator.call(target)
end

puts "\n=== FIX CONDITIONNEMENTS MAL PLACÉS ==="

# 1. Persil France frais 1.035kg @ 188.55€ → Persillade
puts "\n1. Persil (ID 3831) → Persillade"
move_pp(3831, "Persillade", user)

# 2. Tomates Colin 2kg @ 72.84€ → Fond de veau (Fond blanc de veau)
puts "\n2. Tomates Colin (ID 3514) → Fond de veau"
move_pp(3514, "Fond de veau", user)

# 3. Farine T55 Colin 10kg @ 97.3€ → Épeautre bio
puts "\n3. Farine T55 Colin épeautre bio (ID 3865) → Épeautre bio"
# Chercher ou créer le produit Épeautre bio
epeautre = user.products.where("name ILIKE ?", "%peautre%").first
unless epeautre
  epeautre = user.products.create!(name: "Épeautre bio", unit: "kg")
  puts "  ℹ️  Produit 'Épeautre bio' créé (ID #{epeautre.id})"
end
pp3865 = ProductPurchase.find(3865)
source = pp3865.product
pp3865.update!(product: epeautre)
Products::AvgPriceRecalculator.call(source) rescue nil
Products::AvgPriceRecalculator.call(epeautre)
puts "  ✅ PP#3865 : #{source.name} → #{epeautre.name}"

# 4. Morilles Colin 0.5kg @ 98.96€ → Mélange paëlla
puts "\n4. Morilles Colin mélange paella (ID 3957) → Mélange paëlla"
paella = user.products.where("name ILIKE ?", "%pa_lla%").first
paella ||= user.products.where("name ILIKE ?", "%paella%").first
unless paella
  paella = user.products.create!(name: "Mélange paëlla", unit: "kg")
  puts "  ℹ️  Produit 'Mélange paëlla' créé (ID #{paella.id})"
end
pp3957 = ProductPurchase.find(3957)
source = pp3957.product
pp3957.update!(product: paella)
Products::AvgPriceRecalculator.call(source) rescue nil
Products::AvgPriceRecalculator.call(paella)
puts "  ✅ PP#3957 : #{source.name} → #{paella.name}"

# 5 & 6. Morilles ABP 4.5kg @ 15.2€ et 13.5kg @ 45.59€ → Concentré de tomates
puts "\n5-6. Morilles ABP concentré tomates (IDs 3947, 3948) → Concentré de tomates"
concentre = user.products.where("name ILIKE ?", "%concentr%tomat%").first
concentre ||= user.products.where("name ILIKE ?", "%concentr%").first
if concentre
  [3947, 3948].each { |id| move_pp(id, concentre.name, user) }
else
  puts "  ❌ Produit 'Concentré de tomates' introuvable"
end

# 7. Pomme ABP 1kg @ 12.16€ → Compote pomme
puts "\n7. Pomme ABP compote (ID 3345) → Compote pomme"
compote = user.products.where("name ILIKE ?", "%compote%").first
unless compote
  compote = user.products.create!(name: "Compote pomme", unit: "kg")
  puts "  ℹ️  Produit 'Compote pomme' créé (ID #{compote.id})"
end
move_pp(3345, compote.name, user)

puts "\n=== TERMINÉ ==="
