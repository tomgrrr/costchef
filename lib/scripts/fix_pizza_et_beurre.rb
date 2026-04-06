# encoding: utf-8
# frozen_string_literal: true
# Fix groupé :
#   1. Sauce pizza : remet Concentre de tomates à 0.6kg, fixe Tomates à 16.8kg
#   2. Pate a pizza : diagnostique + corrige le beurre (→ Beurre tracé) + ajoute Eau 6kg
#   3. Frangipane : corrige Beurre → Beurre président

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

beurre_doux  = user.products.find_by!("LOWER(name) = ?", "beurre doux")
beurre_trace = user.products.find_by!("name ILIKE ?", "%Beurre trac%")
beurre_pres  = user.products.find_by!("name ILIKE ?", "%Beurre pr%")
eau          = user.products.find_by!("LOWER(name) = ?", "eau")

ActiveRecord::Base.transaction do

  # ── 1. SAUCE PIZZA ────────────────────────────────────────────────────
  puts "=== Sauce pizza ==="
  sauce = user.recipes.find_by!("LOWER(name) = ?", "sauce pizza")

  concentre = user.products.find_by!("LOWER(name) = ?", "concentre de tomates")
  rc_concentre = sauce.recipe_components.find_by(component_type: "Product", component_id: concentre.id)

  if rc_concentre
    puts "  Concentre de tomates actuellement : #{rc_concentre.quantity_kg} kg"
    rc_concentre.update!(quantity_kg: 0.6)
    puts "  [FIX] Concentre de tomates → 0.6 kg"
  else
    puts "  Concentre OK (non touché)"
  end

  # Trouver le vrai produit Tomates (plusieurs noms possibles)
  tomates = user.products.where("LOWER(name) = ?", "tomates").first
  tomates ||= user.products.where("name ILIKE ?", "%Tomates pel%").first
  tomates ||= user.products.where("name ILIKE ?", "%Tomates conc%").first
  tomates ||= user.products.where("name ILIKE ? AND name NOT ILIKE ?", "%Tomat%", "%Concentr%").first
  raise "Produit Tomates introuvable" unless tomates
  puts "  Produit Tomates : #{tomates.name}"

  rc_tomates = sauce.recipe_components.find_by(component_type: "Product", component_id: tomates.id)
  if rc_tomates
    puts "  Tomates actuellement : #{rc_tomates.quantity_kg} kg"
    rc_tomates.update!(quantity_kg: 16.8)
    puts "  [FIX] Tomates → 16.8 kg (4 boites × 4.2 kg)"
  else
    sauce.recipe_components.create!(component: tomates, quantity_kg: 16.8, quantity_unit: "kg")
    puts "  [AJOUT] Tomates 16.8 kg"
  end

  Recipes::Recalculator.call(sauce)
  sauce.reload
  puts "  → #{sauce.cached_cost_per_kg.round(2)} EUR/kg | #{sauce.cached_total_weight.round(2)} kg"

  # ── 2. PATE A PIZZA ───────────────────────────────────────────────────
  puts "\n=== Pate a pizza ==="
  pizza = user.recipes.find_by!("LOWER(name) LIKE ?", "%pate a pizza%")

  puts "  Composants actuels :"
  pizza.recipe_components.includes(:component).each do |rc|
    puts "    #{rc.component.name} : #{rc.quantity_kg} kg"
  end

  # Identifier le composant beurre (quel qu'il soit)
  beurre_ids = user.products.where("name ILIKE ?", "%Beurre%").pluck(:id)
  rc_beurre = pizza.recipe_components.find_by(component_type: "Product", component_id: beurre_ids)

  if rc_beurre
    ancien = user.products.find(rc_beurre.component_id).name
    if rc_beurre.component_id == beurre_trace.id
      puts "  [OK] Beurre tracé déjà correct (#{rc_beurre.quantity_kg} kg)"
    else
      rc_beurre.update!(component_id: beurre_trace.id)
      puts "  [FIX] #{ancien} → Beurre tracé (#{rc_beurre.quantity_kg} kg)"
    end
  else
    pizza.recipe_components.create!(component: beurre_trace, quantity_kg: 7.0, quantity_unit: "kg")
    puts "  [AJOUT] Beurre tracé 7 kg"
  end

  # Ajouter Eau 6kg si absente
  rc_eau = pizza.recipe_components.find_by(component_type: "Product", component_id: eau.id)
  if rc_eau
    puts "  [OK] Eau déjà présente (#{rc_eau.quantity_kg} kg)"
  else
    pizza.recipe_components.create!(component: eau, quantity_kg: 6.0, quantity_unit: "kg")
    puts "  [AJOUT] Eau 6 kg"
  end

  Recipes::Recalculator.call(pizza)
  pizza.reload
  puts "  → #{pizza.cached_cost_per_kg.round(2)} EUR/kg | #{pizza.cached_total_weight.round(2)} kg"

  # ── 3. FRANGIPANE ────────────────────────────────────────────────────
  puts "\n=== Frangipane ==="
  frangipane = user.recipes.find_by!("LOWER(name) = ?", "frangipane")

  puts "  Composants actuels :"
  frangipane.recipe_components.includes(:component).each do |rc|
    puts "    #{rc.component.name} : #{rc.quantity_kg} kg"
  end

  rc_beurre = frangipane.recipe_components
                        .find_by(component_type: "Product", component_id: beurre_doux.id)

  if rc_beurre
    rc_beurre.update!(component_id: beurre_pres.id)
    puts "  [FIX] Beurre doux → Beurre président (#{rc_beurre.quantity_kg} kg)"
  else
    rc_check = frangipane.recipe_components
                         .find_by(component_type: "Product", component_id: beurre_pres.id)
    if rc_check
      puts "  [OK] Beurre président déjà correct (#{rc_check.quantity_kg} kg)"
    else
      frangipane.recipe_components.create!(component: beurre_pres, quantity_kg: 1.5, quantity_unit: "kg")
      puts "  [AJOUT] Beurre président 1.5 kg"
    end
  end

  Recipes::Recalculator.call(frangipane)
  frangipane.reload
  puts "  → #{frangipane.cached_cost_per_kg.round(2)} EUR/kg"

  # ── Cascade : recettes qui utilisent Sauce pizza ──────────────────────
  impactes = RecipeComponent
    .where(component_type: "Recipe", component_id: sauce.id)
    .map(&:parent_recipe).uniq.compact
  if impactes.any?
    puts "\n=== Recalcul cascade Sauce pizza ==="
    impactes.each do |r|
      Recipes::Recalculator.call(r)
      r.reload
      puts "  #{r.name} → #{r.cached_cost_per_kg.round(2)} EUR/kg"
    end
  end

end
