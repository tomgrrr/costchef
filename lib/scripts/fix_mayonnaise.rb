# encoding: utf-8
# frozen_string_literal: true
# Corrige Mayonnaise : Oeuf solide 2kg → Jaune 2kg (jaunes d'oeuf, ODS confirmé)

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

ActiveRecord::Base.transaction do

  mayo = user.recipes.find_by!("LOWER(name) LIKE ?", "%mayonnaise%")
  puts "Recette : #{mayo.name}"

  oeuf_solide = user.products.find_by!("LOWER(name) = ?", "oeuf solide")
  jaune       = user.products.find_by!("LOWER(name) = ?", "jaune")
  puts "  Oeuf solide : #{oeuf_solide.name} (#{oeuf_solide.avg_price_per_kg.round(2)} €/kg)"
  puts "  Jaune       : #{jaune.name} (#{jaune.avg_price_per_kg.round(2)} €/kg)"

  rc = mayo.recipe_components.find_by(component_type: "Product", component_id: oeuf_solide.id)
  raise "Oeuf solide introuvable dans Mayonnaise" unless rc

  puts "  Avant : #{oeuf_solide.name} #{rc.quantity_kg} kg"
  rc.update!(component_id: jaune.id)
  puts "  [FIX] Oeuf solide → Jaune (#{rc.quantity_kg} kg)"

  Recipes::Recalculator.call(mayo)
  mayo.reload
  puts "  → #{mayo.cached_cost_per_kg.round(2)} EUR/kg"

end
