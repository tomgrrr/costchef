# encoding: utf-8
# frozen_string_literal: true
# Corrige le produit "Blanc" (blanc d'oeuf) :
# - base_unit etait "piece" → correction en "kg"
# - Supprime les 15 faux achats (quantites en piece au lieu de kg)
# - Cree 1 achat propre par fournisseur avec les vrais prix
# - Recalcule avg_price_per_kg

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")
blanc = user.products.find_by!("name = ?", "Blanc")

puts "Avant correction :"
puts "  base_unit     : #{blanc.base_unit}"
puts "  avg_price_per_kg : #{blanc.avg_price_per_kg} EUR/kg"
puts "  ProductPurchases : #{blanc.product_purchases.count}"

ActiveRecord::Base.transaction do
  # 1. Corriger le base_unit (et effacer unit_weight_kg qui n'a pas de sens en kg)
  blanc.update_columns(base_unit: "kg", unit_weight_kg: nil)
  puts "\n[OK] base_unit corrige : piece → kg (unit_weight_kg efface)"

  # 2. Supprimer tous les faux achats
  blanc.product_purchases.delete_all
  puts "[OK] #{blanc.product_purchases.reload.count} anciens achats supprimes"

  # 3. Recreer 1 achat propre par fournisseur
  # Source : onglet "Blanc" du fichier prix moyen
  # Format : bidon 2kg (prix unitaire du bidon)
  achats = [
    { supplier_name: "DS restauration", qty: 2.0, price: 9.2,  unit: "kg" },  # 4.60 EUR/kg
    { supplier_name: "ABP",             qty: 2.0, price: 10.37, unit: "kg" }, # 5.185 EUR/kg
    { supplier_name: "France frais",    qty: 2.0, price: 9.65,  unit: "kg" }, # 4.825 EUR/kg
    { supplier_name: "Transgourmet",    qty: 2.0, price: 15.9,  unit: "kg" }, # 7.95 EUR/kg
  ]

  achats.each do |a|
    supplier = user.suppliers.find_by!("name ILIKE ?", a[:supplier_name])
    pp = blanc.product_purchases.create!(
      supplier:          supplier,
      package_quantity:  a[:qty],
      package_price:     a[:price],
      package_unit:      a[:unit],
      active:            true
    )
    puts "  [CREE] #{supplier.name} | #{pp.package_quantity} kg | #{pp.package_price}€ | #{pp.price_per_kg.round(3)}€/kg"
  end

  # 4. Recalculer le prix moyen
  Products::AvgPriceRecalculator.call(blanc)
  blanc.reload

  puts "\nApres correction :"
  puts "  avg_price_per_kg : #{blanc.avg_price_per_kg.round(3)} EUR/kg"

  # 5. Propager aux recettes qui utilisent ce produit
  recettes_impactees = RecipeComponent
    .where(component_type: "Product", component_id: blanc.id)
    .map(&:parent_recipe)
    .uniq
    .compact

  recettes_impactees.each do |r|
    Recipes::Recalculator.call(r)
    r.reload
    puts "  [RECALCUL] #{r.name} → #{r.cached_cost_per_kg.round(3)}€/kg"
  end

  puts "\nTermine."
end
