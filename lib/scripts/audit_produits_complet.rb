# encoding: utf-8
# frozen_string_literal: true
# Audit complet : tous les produits avec leurs conditionnements et prix

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

products = user.products.includes(:product_purchases).order(:name)

puts "=" * 70
puts "AUDIT COMPLET PRODUITS — #{products.count} produits"
puts "=" * 70

products.each do |p|
  avg   = p.avg_price_per_kg.to_f
  condits = p.product_purchases

  # Indicateur de suspicion
  flag = ""
  flag = " 🔴 SANS PRIX"   if avg == 0
  flag = " 🟡 >50€/kg"     if avg > 50
  flag = " 🟡 >20€/kg"     if avg > 20 && avg <= 50
  flag = " 🟡 <0.5€/kg"    if avg > 0 && avg < 0.5

  puts "\n#{p.name} (#{p.base_unit})#{flag}"
  puts "  avg : #{avg.round(3)} €/kg | #{condits.count} conditionnement(s)"

  if condits.any?
    condits.each do |c|
      fournisseur = c.respond_to?(:supplier) && c.supplier ? c.supplier.name : "?"
      puts "    • #{fournisseur.ljust(25)} #{c.package_quantity.to_f} #{c.package_unit} | #{c.package_price.to_f.round(2)}€ total | #{c.price_per_kg.to_f.round(3)} €/kg#{c.active ? '' : ' [inactif]'}"
    end
  end
end

puts "\n" + "=" * 70
puts "RÉSUMÉ"
puts "  Total        : #{products.count}"
puts "  Avec prix    : #{products.select { |p| p.avg_price_per_kg.to_f > 0 }.count}"
puts "  Sans prix    : #{products.select { |p| p.avg_price_per_kg.to_f == 0 }.count}"
puts "  > 50€/kg     : #{products.select { |p| p.avg_price_per_kg.to_f > 50 }.count}"
puts "=" * 70
