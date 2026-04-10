# encoding: utf-8
# ============================================================
# CLEANUP DOUBLONS — Phase 3
# - Oeufs frais solide : unit_weight + conditionnements
# - Oeuf poché (40g)  : création + conditionnements
# ============================================================

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

puts "=" * 60
puts "CLEANUP DOUBLONS 3 — compte : #{user.email}"
puts "=" * 60

# ── Helper fournisseur ────────────────────────────────────────
def find_supplier(user, *patterns)
  patterns.each do |pat|
    s = user.suppliers.where("name ILIKE ?", "%#{pat}%").first
    return s if s
  end
  puts "  ⚠️  Fournisseur introuvable : #{patterns.first} — conditionnement skippé"
  nil
end

def add_purchase(product, supplier, qty, unit, price, label)
  return unless supplier
  pp = product.product_purchases.build(
    supplier:         supplier,
    package_quantity: qty,
    package_unit:     unit,
    package_price:    price
  )
  if pp.save
    puts "    ✓ #{label} — #{qty} #{unit} / #{price}€ → #{pp.price_per_kg.round(4)} €/kg"
  else
    puts "    ❌ #{label} : #{pp.errors.full_messages.join(', ')}"
  end
end

# ============================================================
# ÉTAPE 1 — Oeufs frais solide
# ============================================================
puts "\n── Oeufs frais solide ──"

frais = user.products.where("name ILIKE ?", "%frais solide%").first
if frais.nil?
  puts "  ❌ Produit introuvable — vérifier"
else
  puts "  ✓ Trouvé : #{frais.name} (ID #{frais.id})"

  # Poids unitaire : oeuf gros 63/73g → moyenne 68g
  frais.update!(unit_weight_kg: 0.068)
  puts "  ✓ unit_weight_kg = 0.068 kg (68g)"

  sup_france  = find_supplier(user, "france frais", "france-frais")
  sup_abp     = find_supplier(user, "abp")
  sup_trans   = find_supplier(user, "transgourmet")

  puts "  → Conditionnements :"
  add_purchase(frais, sup_france, 360, "piece", 85.32, "France frais x360")
  add_purchase(frais, sup_france, 180, "piece", 46.62, "France frais x180")
  add_purchase(frais, sup_abp,    360, "piece", 73.15, "ABP x360")
  add_purchase(frais, sup_trans,  180, "piece", 44.90, "Transgourmet x180")
  add_purchase(frais, sup_trans,  360, "piece", 84.00, "Transgourmet x360")
end

# ============================================================
# ÉTAPE 2 — Oeuf poché (40g)
# ============================================================
puts "\n── Oeuf poché ──"

poche = user.products.where("name ILIKE ?", "%oeuf poch%").first
if poche
  puts "  ⚠️  Déjà existant : #{poche.name} (ID #{poche.id})"
else
  poche = user.products.create!(
    name:           "Oeuf poché",
    base_unit:      "piece",
    unit_weight_kg: 0.040
  )
  puts "  ✅ Créé : Oeuf poché (ID #{poche.id}) — 40g/pièce"
end

# Mettre à jour le poids si le produit existait sans poids
if poche.unit_weight_kg.nil? || poche.unit_weight_kg == 0
  poche.update!(unit_weight_kg: 0.040)
  puts "  ✓ unit_weight_kg = 0.040 kg (40g)"
end

sup_ds    = find_supplier(user, "ds restauration", "ds restau", " ds ")
sup_sysco = find_supplier(user, "sysco")

puts "  → Conditionnements :"
add_purchase(poche, sup_ds,    96, "piece", 52.80, "DS x96")
add_purchase(poche, sup_ds,    48, "piece", 26.40, "DS x48")
add_purchase(poche, sup_sysco, 48, "piece", 38.40, "Sysco x48")

puts "\n" + "=" * 60
puts "✅ Cleanup 3 terminé"
puts "=" * 60
