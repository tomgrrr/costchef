# encoding: utf-8
# frozen_string_literal: true
# Audit complet des produits : prix suspects, doublons potentiels, 0€, outliers

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

products = user.products.includes(:product_purchases).order(:name)
total = products.count

puts "=" * 60
puts "AUDIT PRODUITS — #{total} produits au total"
puts "=" * 60

# ── 1. PRODUITS SANS PRIX (0 €/kg) ────────────────────────────
sans_prix = products.select { |p| p.avg_price_per_kg.nil? || p.avg_price_per_kg == 0 }
puts "\n🔴 SANS PRIX (#{sans_prix.count}) :"
sans_prix.each do |p|
  condits = p.product_purchases.count
  puts "  #{p.name.ljust(35)} | #{condits} condit(s) | unit: #{p.base_unit}"
end

# ── 2. PRODUITS SANS CONDITIONNEMENTS ─────────────────────────
sans_condits = products.select { |p| p.product_purchases.empty? }
puts "\n🟠 SANS CONDITIONNEMENTS (#{sans_condits.count}) :"
sans_condits.each do |p|
  puts "  #{p.name.ljust(35)} | #{p.avg_price_per_kg.to_f.round(2)} €/kg | unit: #{p.base_unit}"
end

# ── 3. PRIX TRÈS ÉLEVÉS (> 50 €/kg) ──────────────────────────
chers = products.select { |p| p.avg_price_per_kg.to_f > 50 }
puts "\n🟡 PRIX > 50€/KG (#{chers.count}) :"
chers.each do |p|
  puts "  #{p.name.ljust(35)} | #{p.avg_price_per_kg.round(2)} €/kg | #{p.product_purchases.count} condits"
end

# ── 4. PRIX SUSPECTS (> 20 €/kg — à vérifier) ──────────────
suspects = products.select { |p| p.avg_price_per_kg.to_f > 20 && p.avg_price_per_kg.to_f <= 50 }
puts "\n🟡 PRIX ENTRE 20 ET 50 €/KG (#{suspects.count}) :"
suspects.each do |p|
  puts "  #{p.name.ljust(35)} | #{p.avg_price_per_kg.round(2)} €/kg | #{p.product_purchases.count} condits"
end

# ── 5. PRIX TRÈS BAS (0 < x < 0.5 €/kg) ─────────────────────
trop_bas = products.select { |p| p.avg_price_per_kg.to_f > 0 && p.avg_price_per_kg.to_f < 0.5 }
puts "\n🟡 PRIX TRÈS BAS < 0.5 €/KG (#{trop_bas.count}) :"
trop_bas.each do |p|
  puts "  #{p.name.ljust(35)} | #{p.avg_price_per_kg.round(4)} €/kg | #{p.product_purchases.count} condits"
end

# ── 6. DOUBLONS POTENTIELS (noms similaires) ──────────────────
puts "\n🔵 DOUBLONS POTENTIELS (noms proches) :"
noms = products.map(&:name)
groupes = {}
noms.each do |n|
  racine = n.downcase.gsub(/\s+(sous\s+recette|sr|sye|bi5l|tourage\s+pl).*$/, "").strip.split(/[\s\-\/]/).first(2).join(" ")
  groupes[racine] ||= []
  groupes[racine] << n
end
groupes.each do |racine, groupe|
  puts "  [#{racine}] #{groupe.join(" / ")}" if groupe.size > 1
end

# ── 7. RECAP GÉNÉRAL ──────────────────────────────────────────
with_price = products.select { |p| p.avg_price_per_kg.to_f > 0 }.count
puts "\n" + "=" * 60
puts "RÉSUMÉ"
puts "  Total produits       : #{total}"
puts "  Avec prix            : #{with_price}"
puts "  Sans prix (0€)       : #{sans_prix.count}"
puts "  Sans conditionnements: #{sans_condits.count}"
puts "  Prix > 50€/kg        : #{chers.count}"
puts "=" * 60
