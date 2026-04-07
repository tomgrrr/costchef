# encoding: utf-8
# frozen_string_literal: true
# Audit global : détecte les produits catch-all (prix trop variables) et les 0 condits
# Couvre tous les onglets Excel : Légumes, Poissons, Viandes, Sauce, Laitiers, Fruits, etc.

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")
all_products = user.products.includes(:product_purchases, :recipe_components).order(:name)

catch_alls = []
zero_condits = []

all_products.each do |p|
  condits = p.product_purchases.to_a
  rc_count = p.recipe_components.count

  # ── 0 conditionnement ────────────────────────────────────────────────────
  zero_condits << { id: p.id, name: p.name, rc: rc_count } if condits.empty?

  # ── Variabilité suspecte (potentiel catch-all) ───────────────────────────
  next if condits.size < 3
  prix = condits.map { |c| c.price_per_kg.to_f }.select { |v| v > 0 }
  next if prix.size < 3
  ratio = prix.max / prix.min
  next if ratio < 5

  catch_alls << {
    id:     p.id,
    name:   p.name,
    n:      condits.size,
    min:    prix.min.round(3),
    max:    prix.max.round(3),
    ratio:  ratio.round(1),
    condits: condits
  }
end

# ══ RAPPORT 1 : CATCH-ALLS ═══════════════════════════════════════════════
puts "\n#{'=' * 75}"
puts "PRODUITS CATCH-ALL SUSPECTS (#{catch_alls.size}) — ratio max/min prix > 5x, >= 3 condits"
puts "#{'=' * 75}"

if catch_alls.empty?
  puts "  ✅ Aucun produit catch-all détecté."
else
  catch_alls.sort_by { |c| -c[:ratio] }.each do |c|
    puts "\n  #{c[:name]} (ID #{c[:id]}) — #{c[:n]} condits | #{c[:min]}→#{c[:max]} €/kg (×#{c[:ratio]})"
    puts "  #{'%-5s  %-20s  %8s  %-5s  %10s  %8s' % ['PP_ID', 'Fournisseur', 'Qté', 'Unité', 'Prix total', '€/kg']}"
    c[:condits].includes(:supplier).order(:price_per_kg).each do |pp|
      puts "  #{'%-5s  %-20s  %8.3f  %-5s  %10.2f€  %8.3f' % [pp.id, pp.supplier&.name.to_s, pp.package_quantity.to_f, pp.package_unit.to_s, pp.package_price.to_f, pp.price_per_kg.to_f]}"
    end
  end
end

# ══ RAPPORT 2 : 0 CONDITIONNEMENTS ════════════════════════════════════════
puts "\n\n#{'=' * 75}"
puts "PRODUITS SANS CONDITIONNEMENT (#{zero_condits.size})"
puts "#{'=' * 75}"

if zero_condits.empty?
  puts "  ✅ Tous les produits ont au moins un conditionnement."
else
  zero_condits.sort_by { |z| z[:name] }.each do |z|
    flag = z[:rc] > 0 ? "  ← #{z[:rc]} recette(s)" : "  ← INUTILISÉ"
    puts "  ID #{z[:id]} | #{z[:name]}#{flag}"
  end
end

puts "\n#{'=' * 75}"
puts "RÉSUMÉ"
puts "#{'=' * 75}"
puts "  Produits total          : #{all_products.size}"
puts "  Catch-alls suspects     : #{catch_alls.size}"
puts "  Sans conditionnement    : #{zero_condits.size}"
puts "  Sans condit + en recette: #{zero_condits.count { |z| z[:rc] > 0 }}"
puts "#{'=' * 75}"
