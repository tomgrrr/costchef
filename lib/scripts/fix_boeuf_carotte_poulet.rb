# encoding: utf-8

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")

# ============================================================
# 1. FUSION — Égrainés de bœuf (ID 1082, 0 cond) → Egrene boeuf (ID 1028)
# ============================================================
puts "=== FUSION BOEUF ==="
old_p = Product.find(1082)
new_p = Product.find(1028)
puts "Ancien : ID #{old_p.id} — #{old_p.name} (#{old_p.product_purchases.count} cond)"
puts "Keeper : ID #{new_p.id} — #{new_p.name} (#{new_p.product_purchases.count} cond)"

rc_list = RecipeComponent.where(component_type: "Product", component_id: old_p.id)
puts "#{rc_list.count} recipe_component(s) à migrer"
rc_list.each do |rc|
  existing = RecipeComponent.find_by(parent_recipe_id: rc.parent_recipe_id, component_type: "Product", component_id: new_p.id)
  if existing
    existing.update!(quantity_kg: existing.quantity_kg + rc.quantity_kg)
    rc.destroy!
    puts "  Fusionné dans RC existant (recette #{rc.parent_recipe_id})"
  else
    rc.update!(component_id: new_p.id)
    puts "  Rebranché → #{new_p.name} (recette #{rc.parent_recipe_id})"
  end
end
old_p.delete
puts "Supprimé : ID #{old_p.id}"

puts "Recalcul recettes de #{new_p.name}..."
RecipeComponent.where(component_type: "Product", component_id: new_p.id).pluck(:parent_recipe_id).uniq.each do |rid|
  recipe = Recipe.find(rid)
  Recipes::Recalculator.call(recipe)
  puts "  ✓ #{recipe.name}"
rescue => e
  puts "  ✗ #{rid} : #{e.message}"
end

# ============================================================
# 2. CAROTTE (ID 904) — ajout conditionnement Jallet 20kg / 28€
# ============================================================
puts ""
puts "=== CAROTTE ==="
carotte = Product.find(904)
puts "Produit : ID #{carotte.id} — #{carotte.name} | base_unit: #{carotte.base_unit}"

supplier = user.suppliers.where("name ILIKE ?", "jallet").first
supplier ||= user.suppliers.create!(name: "Jallet")
puts "Fournisseur : #{supplier.name} (ID #{supplier.id})"

existing_pp = carotte.product_purchases.find_by(supplier: supplier, package_quantity: 20, package_unit: "kg")
if existing_pp
  puts "Conditionnement déjà existant — skip"
else
  pp = ProductPurchase.create!(product: carotte, supplier: supplier, package_quantity: 20, package_unit: "kg", package_price: 28.0)
  puts "Conditionnement créé : ID #{pp.id} | 20 kg | 28.00€"
end

Products::AvgPriceRecalculator.call(carotte)
puts "avg_price_per_kg : #{carotte.reload.avg_price_per_kg}€/kg"

puts "Recalcul recettes de #{carotte.name}..."
RecipeComponent.where(component_type: "Product", component_id: carotte.id).pluck(:parent_recipe_id).uniq.each do |rid|
  recipe = Recipe.find(rid)
  Recipes::Recalculator.call(recipe)
  puts "  ✓ #{recipe.name}"
rescue => e
  puts "  ✗ #{rid} : #{e.message}"
end

# ============================================================
# 3. BLANC DE POULET (ID 1197) — récupère les conditionnements de "Poulet"
# ============================================================
puts ""
puts "=== BLANC DE POULET ==="
blanc = Product.find(1197)
poulet = user.products.where("name ILIKE ?", "poulet").where.not(id: blanc.id).first

if poulet.nil?
  puts "Produit 'Poulet' introuvable — vérifier le nom exact"
else
  puts "Source : ID #{poulet.id} — #{poulet.name} (#{poulet.product_purchases.count} conditionnements)"
  puts "Cible  : ID #{blanc.id} — #{blanc.name}"

  poulet.product_purchases.each do |pp|
    new_pp = pp.dup
    new_pp.product = blanc
    new_pp.save!
    puts "  Conditionnement migré : #{pp.package_quantity} #{pp.package_unit} | #{pp.package_price}€ (#{pp.supplier&.name})"
  end

  # Recalcul Blanc de poulet
  Products::AvgPriceRecalculator.call(blanc)
  puts "avg_price_per_kg Blanc de poulet : #{blanc.reload.avg_price_per_kg}€/kg"

  # Supprimer Poulet (pas de RC à migrer)
  poulet.delete
  puts "Supprimé : ID #{poulet.id} — #{poulet.name}"

  puts "Recalcul recettes de #{blanc.name}..."
  RecipeComponent.where(component_type: "Product", component_id: blanc.id).pluck(:parent_recipe_id).uniq.each do |rid|
    recipe = Recipe.find(rid)
    Recipes::Recalculator.call(recipe)
    puts "  ✓ #{recipe.name}"
  rescue => e
    puts "  ✗ #{rid} : #{e.message}"
  end
end

puts ""
puts "Done."
