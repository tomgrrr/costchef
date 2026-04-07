# encoding: utf-8
# frozen_string_literal: true
# Liste tous les conditionnements de "morceaux" et "Mélange" pour identification

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

["morceaux", "Mélange", "Thon"].each do |nom|
  p = user.products.find_by("name = ?", nom)
  unless p
    puts "\n❌ Produit '#{nom}' introuvable"
    next
  end

  condits = p.product_purchases.includes(:supplier).order(:supplier_id, :package_quantity)
  puts "\n" + "=" * 70
  puts "PRODUIT : #{p.name} (ID #{p.id}) — #{condits.count} conditionnements"
  puts "=" * 70
  puts "  %-5s  %-20s  %8s  %-6s  %10s  %10s  %s" % [
    "PP_ID", "Fournisseur", "Qté", "Unité", "Prix total", "€/kg", "Désignation / note"
  ]
  puts "  " + "-" * 85

  condits.each do |c|
    fournisseur = c.supplier&.name || "?"
    ppu = c.price_per_kg.to_f
    puts "  %-5s  %-20s  %8.3f  %-6s  %10.2f€  %10.3f  %s" % [
      c.id,
      fournisseur,
      c.package_quantity.to_f,
      c.package_unit.to_s,
      c.package_price.to_f,
      ppu,
      c.respond_to?(:notes) ? c.notes.to_s : ""
    ]
  end
end
