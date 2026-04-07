# encoding: utf-8
# frozen_string_literal: true
# Supprime les conditionnements en double (même fournisseur + même qty + même prix + même unité)
# Conserve le plus ancien (ID le plus bas), supprime les suivants.
# Recalcule le prix moyen de chaque produit affecté.

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

total_supprimes = 0
produits_touches = []

user.products.includes(:product_purchases).order(:name).each do |p|
  condits = p.product_purchases.order(:id).to_a
  next if condits.size < 2

  groupes = condits.group_by { |c| [c.supplier_id, c.package_quantity.to_f, c.package_price.to_f, c.package_unit] }

  doublons_produit = []
  groupes.each do |_key, groupe|
    next if groupe.size < 2
    # Garder le premier (ID le plus bas), supprimer les suivants
    a_supprimer = groupe[1..]
    a_supprimer.each do |pp|
      pp.destroy!
      doublons_produit << pp.id
      total_supprimes += 1
    end
  end

  next if doublons_produit.empty?

  Products::AvgPriceRecalculator.call(p)
  p.reload
  puts "  #{p.name} — #{doublons_produit.size} doublon(s) supprimé(s) (IDs: #{doublons_produit.join(', ')}) → avg #{p.avg_price_per_kg.to_f.round(3)} €/kg"
  produits_touches << p.name
end

puts "\n=========================================="
puts "TERMINÉ"
puts "  #{total_supprimes} ProductPurchase(s) supprimé(s)"
puts "  #{produits_touches.size} produit(s) recalculé(s)"
puts "=========================================="
