# encoding: utf-8
# frozen_string_literal: true
# Fusionne "Pied de cochon" → "Pieds de porc"
# Les deux désignent le même produit. "Pieds de porc" a les conditionnements Salaison.

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

puts "=== FUSION Pied de cochon → Pieds de porc ==="

cible  = user.products.find_by("name ILIKE ?", "Pieds de porc")
source = user.products.find_by("name ILIKE ?", "%pied%cochon%")

unless cible
  puts "  ⚠️  'Pieds de porc' introuvable — vérifier le nom exact"
  exit
end

unless source
  puts "  ℹ️  'Pied de cochon' introuvable — rien à faire"
  exit
end

if source.id == cible.id
  puts "  ℹ️  Même produit, rien à faire"
  exit
end

puts "  Cible  : '#{cible.name}'  (ID #{cible.id}) — #{cible.product_purchases.count} condit(s) | #{cible.recipe_components.count} recette(s)"
puts "  Source : '#{source.name}' (ID #{source.id}) — #{source.product_purchases.count} condit(s) | #{source.recipe_components.count} recette(s)"

ActiveRecord::Base.transaction do
  # Transférer les recipe_components si besoin
  rc_count = RecipeComponent.where(component_type: "Product", component_id: source.id).count
  if rc_count > 0
    RecipeComponent.where(component_type: "Product", component_id: source.id)
                   .update_all(component_id: cible.id)
    puts "  ✅ #{rc_count} RecipeComponent(s) rerattaché(s) → #{cible.name}"
  end

  # Transférer les product_purchases si besoin
  pp_count = source.product_purchases.count
  if pp_count > 0
    source.product_purchases.update_all(product_id: cible.id)
    puts "  ✅ #{pp_count} ProductPurchase(s) transféré(s) → #{cible.name}"
    Products::AvgPriceRecalculator.call(cible)
    cible.reload
    puts "  ✅ Prix moyen recalculé → #{cible.avg_price_per_kg.to_f.round(3)} €/kg"
  end

  source.destroy!
  puts "  🗑️  '#{source.name}' supprimé"
end

puts "\n=== TERMINÉ ==="
