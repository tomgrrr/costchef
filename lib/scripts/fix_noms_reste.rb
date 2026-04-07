# encoding: utf-8
# frozen_string_literal: true
# Corrige les 2 cas restants : Basmati + fusion Mayonnaise

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

# 1. Basmati → Riz Basmati (recherche ILIKE pour ignorer espaces/casse)
puts "\n1. Basmati → Riz Basmati"
basmati = user.products.where("name ILIKE ?", "%basmati%")
                       .where("name NOT ILIKE ?", "%riz%")
                       .first
if basmati
  puts "  Trouvé : '#{basmati.name}' (ID #{basmati.id})"
  basmati.update!(name: "Riz Basmati")
  puts "  ✅ Renommé → Riz Basmati"
else
  puts "  ⚠️  Introuvable"
end

# 2. Fusion : mayonnise tube (ID 1016) → Mayonnaise (ID 1089)
puts "\n2. Fusion Mayonnaise"
source = user.products.find_by(id: 1016)
target = user.products.find_by(id: 1089)

if source && target
  nb = source.product_purchases.count
  puts "  Source : '#{source.name}' (ID #{source.id}) — #{nb} condit(s)"
  puts "  Cible  : '#{target.name}' (ID #{target.id})"

  source.product_purchases.update_all(product_id: target.id)
  puts "  ✅ #{nb} conditionnement(s) transféré(s)"

  # Supprimer le produit source s'il n'est plus référencé
  if source.recipe_components.count == 0
    source.destroy!
    puts "  ✅ Produit source supprimé"
  else
    puts "  ⚠️  Produit source lié à des recettes — non supprimé, à vérifier"
  end

  Products::AvgPriceRecalculator.call(target)
  puts "  ✅ Prix moyen Mayonnaise recalculé"
else
  puts "  ⚠️  Source ou cible introuvable (ID 1016 / 1089)"
end

puts "\n=== TERMINÉ ==="
