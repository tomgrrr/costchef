# encoding: utf-8
# frozen_string_literal: true
# Split "Beurre" (26 conditionnements mélangés) en 5 produits distincts :
# Beurre doux, Beurre motte, Beurre président, Beurre AOP, Beurre tracé
#
# AVANT : 1 produit "Beurre" avec 26 condits mélangés à 9.47€/kg
# APRÈS  :
#   - "Beurre doux"      (renommage de "Beurre") → condits Sysco + Transgourmet doux
#   - "Beurre motte"     (nouveau)               → condits Sysco motte + Magpra
#   - "Beurre président" (nouveau)               → condit ABP président
#   - "Beurre AOP"       (nouveau)               → condits ABP AOP
#   - "Beurre tracé"     (existant, 0 condits)   → condits ABP + Transgourmet flechard

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

beurre       = user.products.find_by!("name = ?", "Beurre")
beurre_trace = user.products.find_by!("name ILIKE ?", "%tracé%")

puts "=== AVANT ==="
puts "Beurre        : #{beurre.avg_price_per_kg.round(2)} EUR/kg — #{beurre.product_purchases.count} conditionnements"
puts "Beurre tracé  : #{beurre_trace.avg_price_per_kg.round(2)} EUR/kg — #{beurre_trace.product_purchases.count} conditionnements"

ActiveRecord::Base.transaction do

  # ── Fournisseurs ──────────────────────────────────────────────────────
  sysco        = user.suppliers.find_by!("name ILIKE ?", "%sysco%")
  transgourmet = user.suppliers.find_by!("name ILIKE ?", "%transgourmet%")
  abp          = user.suppliers.find_by!("name ILIKE ?", "%abp%")
  magpra       = user.suppliers.find_by!("name ILIKE ?", "%magpra%")

  # ── 1. Vider tous les conditionnements de "Beurre" (mal classés) ──────
  n = beurre.product_purchases.count
  beurre.product_purchases.delete_all
  puts "\n[SUPPRIME] #{n} conditionnements supprimés de 'Beurre'"

  # ── 2. Renommer "Beurre" → "Beurre doux" ─────────────────────────────
  beurre.update!(name: "Beurre doux")
  beurre_doux = beurre   # alias pour la lisibilité
  puts "[RENOMME] Beurre → Beurre doux (ID #{beurre_doux.id} conservé — liens recettes OK)"

  # ── 3. Créer les produits manquants ───────────────────────────────────
  beurre_motte = user.products.find_by("name = ?", "Beurre motte") ||
                 user.products.create!(name: "Beurre motte", base_unit: "kg", avg_price_per_kg: 0)
  beurre_pres  = user.products.find_by("name = ?", "Beurre président") ||
                 user.products.create!(name: "Beurre président", base_unit: "kg", avg_price_per_kg: 0)
  beurre_aop   = user.products.find_by("name = ?", "Beurre AOP") ||
                 user.products.create!(name: "Beurre AOP", base_unit: "kg", avg_price_per_kg: 0)
  puts "[CREE] Beurre motte / Beurre président / Beurre AOP"

  # ── 4. BEURRE DOUX ────────────────────────────────────────────────────
  # Sysco bulk 100kg à 7.27€/kg + Transgourmet lingot/rouleau
  puts "\n--- Beurre doux ---"
  [
    # [supplier,      qty,    price_per_kg]
    [sysco,        100.0,   7.27],   # Sysco bloc 100kg
    [transgourmet,  10.0,   9.85],   # Transgourmet lingot 10kg
    [transgourmet,  20.0,   9.40],   # Transgourmet lingot 20kg
    [transgourmet,  10.0,   9.90],   # Transgourmet lingot 10kg (autre tarif)
    [transgourmet,  10.0,  10.50],   # Transgourmet rouleau 10kg
  ].each do |supplier, qty, ppu|
    total = (qty * ppu).round(3)
    pp = beurre_doux.product_purchases.create!(
      supplier: supplier, package_quantity: qty, package_price: total, package_unit: "kg", active: true
    )
    puts "  [CREE] #{supplier.name} | #{qty}kg | #{total}€ | #{pp.price_per_kg.round(3)}€/kg"
  end
  Products::AvgPriceRecalculator.call(beurre_doux)
  beurre_doux.reload
  puts "  → avg Beurre doux : #{beurre_doux.avg_price_per_kg.round(3)} EUR/kg"

  # ── 5. BEURRE MOTTE ───────────────────────────────────────────────────
  # Sysco motte baratte 5kg*2=10kg + Magpra beurre doux motte 10kg
  puts "\n--- Beurre motte ---"
  [
    [sysco,   10.0, 10.66],   # Beurre motte baratte 5kg*2
    [magpra,  10.0,  8.90],   # Beurre doux 82% motte 10kg
  ].each do |supplier, qty, ppu|
    total = (qty * ppu).round(3)
    pp = beurre_motte.product_purchases.create!(
      supplier: supplier, package_quantity: qty, package_price: total, package_unit: "kg", active: true
    )
    puts "  [CREE] #{supplier.name} | #{qty}kg | #{total}€ | #{pp.price_per_kg.round(3)}€/kg"
  end
  Products::AvgPriceRecalculator.call(beurre_motte)
  beurre_motte.reload
  puts "  → avg Beurre motte : #{beurre_motte.avg_price_per_kg.round(3)} EUR/kg"

  # ── 6. BEURRE PRÉSIDENT ───────────────────────────────────────────────
  # ABP Beurre président doux 20*500g (30kg)
  puts "\n--- Beurre président ---"
  total = (30.0 * 10.63).round(3)
  pp = beurre_pres.product_purchases.create!(
    supplier: abp, package_quantity: 30.0, package_price: total, package_unit: "kg", active: true
  )
  puts "  [CREE] #{abp.name} | 30kg | #{total}€ | #{pp.price_per_kg.round(3)}€/kg"
  Products::AvgPriceRecalculator.call(beurre_pres)
  beurre_pres.reload
  puts "  → avg Beurre président : #{beurre_pres.avg_price_per_kg.round(3)} EUR/kg"

  # ── 7. BEURRE AOP ─────────────────────────────────────────────────────
  # ABP Beurre ch/Poitou AOP Montaigu pl 2kgsx5 (10kg) × 3 entrées
  puts "\n--- Beurre AOP ---"
  3.times do
    total = (10.0 * 12.892).round(3)
    pp = beurre_aop.product_purchases.create!(
      supplier: abp, package_quantity: 10.0, package_price: total, package_unit: "kg", active: true
    )
    puts "  [CREE] #{abp.name} | 10kg | #{total}€ | #{pp.price_per_kg.round(3)}€/kg"
  end
  Products::AvgPriceRecalculator.call(beurre_aop)
  beurre_aop.reload
  puts "  → avg Beurre AOP : #{beurre_aop.avg_price_per_kg.round(3)} EUR/kg"

  # ── 8. BEURRE TRACÉ (flechard coloré) ────────────────────────────────
  # ABP flechard + Transgourmet flechard or lingot 1kg
  puts "\n--- Beurre tracé ---"
  [
    # [supplier,      qty,   price_per_kg,  commentaire]
    [abp,          10.0,  9.88,  "Flechard beurre doux rlx"],
    [abp,          10.0,  9.45,  "Motte flechard 10kgs"],
    [abp,          10.0,  9.45,  "Motte flechard 10kgs"],
    [abp,          10.0,  9.45,  "Motte flechard 10kgs"],
    [abp,          10.0,  9.92,  "Coloré flechard lingot 1kg"],
    [transgourmet, 30.0,  9.95,  "Beurre flechard or lingot 1kg"],
    [transgourmet, 30.0,  9.95,  "Beurre flechard or lingot 1kg"],
    [transgourmet, 30.0,  9.95,  "Beurre flechard or lingot 1kg"],
    [transgourmet, 30.0,  9.95,  "Beurre flechard or lingot 1kg"],
    [transgourmet, 20.0,  8.50,  "Flechard lingot 20kg"],
    [transgourmet, 20.0,  9.50,  "Flechard lingot 20kg (tarif 2)"],
    [transgourmet, 20.0,  9.50,  "Flechard lingot 20kg (tarif 2)"],
  ].each do |supplier, qty, ppu, _desc|
    total = (qty * ppu).round(3)
    pp = beurre_trace.product_purchases.create!(
      supplier: supplier, package_quantity: qty, package_price: total, package_unit: "kg", active: true
    )
    puts "  [CREE] #{supplier.name} | #{qty}kg | #{total}€ | #{pp.price_per_kg.round(3)}€/kg"
  end
  Products::AvgPriceRecalculator.call(beurre_trace)
  beurre_trace.reload
  puts "  → avg Beurre tracé : #{beurre_trace.avg_price_per_kg.round(3)} EUR/kg"

  # ── 9. Recalculer les recettes qui utilisent "Beurre doux" ────────────
  # (les liens RecipeComponent pointent toujours vers beurre_doux.id)
  recettes = RecipeComponent
    .where(component_type: "Product", component_id: beurre_doux.id)
    .map(&:parent_recipe)
    .uniq
    .compact

  if recettes.any?
    puts "\n--- Recalcul recettes impactées (Beurre doux) ---"
    recettes.each do |r|
      Recipes::Recalculator.call(r)
      r.reload
      puts "  [RECALCUL] #{r.name} → #{r.cached_cost_per_kg.round(3)}€/kg"
    end
  else
    puts "\n[INFO] Aucune recette ne référence encore Beurre doux"
  end

  # ── Récap final ────────────────────────────────────────────────────────
  puts "\n=== APRÈS ==="
  [beurre_doux, beurre_motte, beurre_pres, beurre_aop, beurre_trace].each do |p|
    p.reload
    puts "  #{p.name.ljust(20)} → #{p.avg_price_per_kg.round(3)} EUR/kg — #{p.product_purchases.count} condits"
  end

end
