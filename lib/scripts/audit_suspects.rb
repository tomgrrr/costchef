# encoding: utf-8
# frozen_string_literal: true
# Audit suspects : doublons de conditionnements + prix aberrants

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

products = user.products.includes(:product_purchases).order(:name)

doublons       = []
prix_suspects  = []

products.each do |p|
  condits = p.product_purchases.to_a
  next if condits.empty?

  avg = p.avg_price_per_kg.to_f

  # ── 1. DOUBLONS : même fournisseur + même qty + même prix ──────────────
  groupes = condits.group_by { |c| [c.supplier_id, c.package_quantity.to_f, c.package_price.to_f, c.package_unit] }
  groupes.each do |key, groupe|
    next if groupe.size < 2
    supplier_name = groupe.first.respond_to?(:supplier) && groupe.first.supplier ? groupe.first.supplier.name : "?"
    doublons << {
      produit:      p.name,
      fournisseur:  supplier_name,
      qty:          key[1],   # package_quantity
      prix_total:   key[2],   # package_price
      unite:        key[3],   # package_unit
      n:            groupe.size,
      ids:          groupe.map(&:id).join(", ")
    }
  end

  # ── 2. PRIX SUSPECTS ──────────────────────────────────────────────────
  # a) Prix total manifestement décalé d'un facteur 10 ou 100 par rapport aux autres condits
  if condits.size >= 2
    prix_kg_valides = condits.map { |c| c.price_per_kg.to_f }.select { |v| v > 0 }
    next if prix_kg_valides.size < 2

    median = prix_kg_valides.sort[prix_kg_valides.size / 2]
    next if median == 0

    condits.each do |c|
      v = c.price_per_kg.to_f
      next if v == 0
      ratio = v / median
      # Suspect si > 5x ou < 0.2x la médiane du même produit
      if ratio > 5 || ratio < 0.2
        supplier_name = c.respond_to?(:supplier) && c.supplier ? c.supplier.name : "?"
        prix_suspects << {
          produit:      p.name,
          fournisseur:  supplier_name,
          qty:          c.package_quantity.to_f,
          unite:        c.package_unit,
          prix_total:   c.package_price.to_f,
          prix_kg:      v.round(3),
          median_kg:    median.round(3),
          ratio:        ratio.round(1),
          id:           c.id
        }
      end
    end
  end

  # b) Prix unitaire absurde en absolu (> 200 €/kg hors produits finis connus)
  produits_finis_ok = %w[nougat moelleux tatin flan muffin tartelette tiramisu kouglof macaron paris-brest eclair choux]
  est_produit_fini = produits_finis_ok.any? { |k| p.name.downcase.include?(k) }
  unless est_produit_fini
    condits.each do |c|
      v = c.price_per_kg.to_f
      next if v == 0 || v <= 200
      supplier_name = c.respond_to?(:supplier) && c.supplier ? c.supplier.name : "?"
      # Eviter les doublons avec la section ratio
      already_listed = prix_suspects.any? { |s| s[:id] == c.id }
      unless already_listed
        prix_suspects << {
          produit:      p.name,
          fournisseur:  supplier_name,
          qty:          c.package_quantity.to_f,
          unite:        c.package_unit,
          prix_total:   c.package_price.to_f,
          prix_kg:      v.round(3),
          median_kg:    nil,
          ratio:        nil,
          id:           c.id
        }
      end
    end
  end
end

# ══ RAPPORT ══════════════════════════════════════════════════════════════

puts "\n" + "=" * 70
puts "DOUBLONS DE CONDITIONNEMENTS (#{doublons.size})"
puts "= même fournisseur + même quantité + même prix ="
puts "=" * 70

if doublons.empty?
  puts "  Aucun doublon détecté."
else
  doublons.each do |d|
    puts "\n  #{d[:produit]}"
    puts "    Fournisseur : #{d[:fournisseur]}"
    puts "    Conditionnement : #{d[:qty]} #{d[:unite]} @ #{d[:prix_total]}€  (#{d[:n]}x en double)"
    puts "    IDs ProductPurchase : #{d[:ids]}"
  end
end

puts "\n" + "=" * 70
puts "PRIX SUSPECTS (#{prix_suspects.size})"
puts "= ratio >5x ou <0.2x la médiane du produit, ou >200€/kg ="
puts "=" * 70

if prix_suspects.empty?
  puts "  Aucun prix suspect détecté."
else
  prix_suspects.sort_by { |s| -s[:prix_kg] }.each do |s|
    puts "\n  #{s[:produit]}"
    puts "    Fournisseur : #{s[:fournisseur]}"
    puts "    Conditionnement : #{s[:qty]} #{s[:unite]} @ #{s[:prix_total]}€ → #{s[:prix_kg]} €/kg"
    if s[:median_kg]
      puts "    Médiane produit : #{s[:median_kg]} €/kg  (ratio : ×#{s[:ratio]})"
    end
    puts "    ID : #{s[:id]}"
  end
end

puts "\n" + "=" * 70
