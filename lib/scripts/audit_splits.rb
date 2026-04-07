# encoding: utf-8
# frozen_string_literal: true
# Liste les conditionnements (PP_ID + fournisseur + qty + €/kg) de tous les produits à splitter

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

produits = [
  "Champignons billes",
  "Ail",
  "Echalote",
  "Oignons",
  "Saumon",
  "Thon",
  "Poireaux",
  "Courgette",
  "Tomates",
  "Mélange",
  "Surimi",
  "Moule",
  "Crevettes",
  "Carotte",
]

produits.each do |nom|
  p = user.products.where("name ILIKE ?", nom).first
  unless p
    puts "\n❌ '#{nom}' introuvable"
    next
  end

  condits = p.product_purchases.includes(:supplier).order(:price_per_kg)
  puts "\n#{'=' * 65}"
  puts "#{p.name} (ID #{p.id}) — #{condits.count} condits"
  puts "#{'=' * 65}"
  puts "  %-5s  %-22s  %8s  %-6s  %10s  %8s" % ["PP_ID", "Fournisseur", "Qté", "Unité", "Prix total", "€/kg"]
  puts "  " + "-" * 65
  condits.each do |c|
    puts "  %-5s  %-22s  %8.3f  %-6s  %10.2f€  %8.3f" % [
      c.id,
      c.supplier&.name.to_s,
      c.package_quantity.to_f,
      c.package_unit.to_s,
      c.package_price.to_f,
      c.price_per_kg.to_f
    ]
  end
end
