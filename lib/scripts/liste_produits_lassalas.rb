# encoding: utf-8
# Liste tous les produits (Product) en base pour Lassalas
# Colonnes : ID | Nom | Fournisseur actif | Prix/kg actif (PON) | Nb conditionnements | Unité de base

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")
abort "User introuvable" unless user

products = user.products.includes(product_purchases: :supplier).order(:name)

puts "=== PRODUITS LASSALAS (#{products.count} total) ==="
puts "ID\tNom\tFournisseur(s)\tPrix/kg actif\tNb cond.\tBase unit"

products.each do |p|
  active_purchases = p.product_purchases.select(&:active)

  # Prix pondéré actif (même logique que weighted_avg_price_per_kg dans le contrôleur)
  if active_purchases.any?
    total_qty   = active_purchases.sum { |pp| pp.package_quantity_kg.to_f }
    total_value = active_purchases.sum { |pp| pp.package_quantity_kg.to_f * pp.price_per_kg.to_f }
    pon = total_qty > 0 ? (total_value / total_qty).round(4) : nil
  else
    pon = nil
  end

  suppliers = active_purchases.map { |pp| pp.supplier&.name }.compact.uniq.join(", ")
  suppliers = "—" if suppliers.blank?

  puts [
    p.id,
    p.name,
    suppliers,
    pon ? "#{pon} €/kg" : "pas de prix actif",
    p.product_purchases.count,
    p.base_unit
  ].join("\t")
end

puts ""
puts "Total : #{products.count} produits"
