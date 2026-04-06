# encoding: utf-8
# frozen_string_literal: true
# Corrige les mauvais types de beurre dans batch3 :
#   - Pate a pizza    : Beurre doux 7kg  → Beurre tracé 7kg  + Eau 6kg manquante
#   - Frangipane      : Beurre doux 1.5kg → Beurre président 1.5kg
# PRÉ-REQUIS : fix_beurre.rb exécuté (Beurre doux / Beurre tracé / Beurre président en base)

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

beurre_doux = user.products.find_by!("LOWER(name) = ?", "beurre doux")
beurre_trace = user.products.find_by!("name ILIKE ?", "%Beurre trac%")
beurre_pres  = user.products.find_by!("name ILIKE ?", "%Beurre pr%")
eau          = user.products.find_by!("LOWER(name) = ?", "eau")

ActiveRecord::Base.transaction do

  # ── PATE A PIZZA ─────────────────────────────────────────────────────
  pizza = user.recipes.find_by!("LOWER(name) LIKE ?", "%pate a pizza%")
  puts "Recette : #{pizza.name}"

  rc_beurre = pizza.recipe_components
                   .find_by(component_type: "Product", component_id: beurre_doux.id)
  raise "Beurre doux introuvable dans Pate a pizza" unless rc_beurre

  rc_beurre.update!(component_id: beurre_trace.id)
  puts "  [FIX] Beurre doux 7kg → Beurre tracé 7kg"

  # Ajouter Eau 6kg manquante
  pizza.recipe_components.create!(component: eau, quantity_kg: 6.0, quantity_unit: "kg")
  puts "  [AJOUT] Eau 6kg"

  Recipes::Recalculator.call(pizza)
  pizza.reload
  puts "  → #{pizza.recipe_components.count} composants | #{pizza.cached_cost_per_kg.round(2)} EUR/kg | #{pizza.cached_total_weight.round(2)} kg"

  # ── FRANGIPANE ───────────────────────────────────────────────────────
  frangipane = user.recipes.find_by!("LOWER(name) = ?", "frangipane")
  puts "\nRecette : #{frangipane.name}"

  rc_beurre = frangipane.recipe_components
                        .find_by(component_type: "Product", component_id: beurre_doux.id)
  raise "Beurre doux introuvable dans Frangipane" unless rc_beurre

  rc_beurre.update!(component_id: beurre_pres.id)
  puts "  [FIX] Beurre doux 1.5kg → Beurre président 1.5kg"

  Recipes::Recalculator.call(frangipane)
  frangipane.reload
  puts "  → #{frangipane.recipe_components.count} composants | #{frangipane.cached_cost_per_kg.round(2)} EUR/kg"

end
