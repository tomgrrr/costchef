# encoding: utf-8
# Liste tous les produits de l'utilisateur avec leur statut de prix
# Pour rapprocher les noms de factures avec les noms en base

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")
abort "User introuvable" unless user

products = user.products.includes(:product_purchases).order("name ASC")

puts "=== TOUS LES PRODUITS LASSALAS (#{products.count} total) ==="
puts ""
puts "%-6s | %-10s | %-3s | %-50s | %s" % ["ID", "avg_prix/kg", "cond", "Nom", "Statut"]
puts "-" * 100

products.each do |p|
  nb   = p.product_purchases.size
  avg  = p.avg_price_per_kg
  status = if nb == 0
    "❌ SANS PRIX"
  elsif avg.nil? || avg == 0
    "⚠️  COND SANS PRIX"
  else
    "✅ OK"
  end
  avg_str = avg&.positive? ? "#{avg.round(3)}€" : "—"
  puts "%-6s | %-10s | %-3s | %-50s | %s" % [p.id, avg_str, nb, p.name[0..49], status]
end

puts ""
puts "--- RÉSUMÉ ---"
total     = products.count
sans_prix = products.select { |p| p.product_purchases.empty? }.count
avec_prix = total - sans_prix
puts "Total      : #{total}"
puts "Avec prix  : #{avec_prix}"
puts "Sans prix  : #{sans_prix}"
