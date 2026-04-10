# encoding: utf-8

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")

def merge_product(old_p, new_p)
  puts "  #{old_p.name} (ID #{old_p.id}) → #{new_p.name} (ID #{new_p.id})"
  rc_list = RecipeComponent.where(component_type: "Product", component_id: old_p.id)
  puts "  #{rc_list.count} recipe_component(s) à migrer"
  rc_list.each do |rc|
    existing = RecipeComponent.find_by(parent_recipe_id: rc.parent_recipe_id, component_type: "Product", component_id: new_p.id)
    if existing
      existing.update!(quantity_kg: existing.quantity_kg + rc.quantity_kg)
      rc.destroy!
      puts "    Doublon fusionné (recette #{rc.parent_recipe_id})"
    else
      rc.update!(component_id: new_p.id)
      puts "    Rebranché (recette #{rc.parent_recipe_id})"
    end
  end
  old_p.delete
  puts "  Supprimé : #{old_p.name}"
end

def add_cond(product, supplier, qty, unit, price)
  existing = product.product_purchases.find_by(supplier: supplier, package_quantity: qty, package_unit: unit)
  if existing
    puts "  Déjà existant — skip"
  else
    pp = ProductPurchase.create!(product: product, supplier: supplier, package_quantity: qty, package_unit: unit, package_price: price)
    puts "  Créé : #{qty}#{unit} | #{price}€ (ID #{pp.id})"
  end
  Products::AvgPriceRecalculator.call(product)
  puts "  avg_price_per_kg : #{product.reload.avg_price_per_kg}€/kg"
end

colin = user.suppliers.where("name ILIKE ?", "colin").first_or_create!(name: "Colin")

# ============================================================
# 1. FUSIONS — branchement sur produits déjà pricés
# ============================================================
puts "=== FUSIONS ==="

# sauce st jacques (ID 1224) → Sauce aux st jacques (déjà pricé Colin 34.79€/kg)
puts ""
puts "--- sauce st jacques → Sauce aux st jacques ---"
old_p = user.products.find_by(id: 1224)
new_p = user.products.where("name ILIKE ?", "sauce aux st jacques").where.not(id: 1224).first
if old_p && new_p
  merge_product(old_p, new_p)
else
  puts "  Introuvable — skip (old:#{old_p&.id} new:#{new_p&.id})"
end

# Vinaigre (ID 1087) → Vinaigre de vin (ID 1090)
puts ""
puts "--- Vinaigre → Vinaigre de vin ---"
old_p = user.products.find_by(id: 1087)
new_p = user.products.find_by(id: 1090)
if old_p && new_p
  merge_product(old_p, new_p)
else
  puts "  Introuvable — skip"
end

puts ""

# ============================================================
# 2. CONDITIONNEMENTS — prix depuis onglet Moyenne ODS
# ============================================================
puts "=== CONDITIONNEMENTS ==="

# Levure (ID 1060) — 3.00€/kg
puts ""
puts "--- Levure ---"
p = user.products.find_by(id: 1060)
if p
  add_cond(p, colin, 1, "kg", 3.00)
else
  puts "  Introuvable"
end

# jus langoustine (ID 1222) — Jus de langoustine en pâte, 29.35€/kg
puts ""
puts "--- jus langoustine ---"
p = user.products.find_by(id: 1222)
if p
  add_cond(p, colin, 1, "kg", 29.35)
else
  puts "  Introuvable"
end

# concentre tomate (ID 1219) — Concentré tomates, 3.38€/kg
puts ""
puts "--- concentre tomate ---"
p = user.products.find_by(id: 1219)
if p
  add_cond(p, colin, 1, "kg", 3.38)
else
  puts "  Introuvable"
end

# Poudre amande blanche (ID 1098) — 7.92€/kg
puts ""
puts "--- Poudre amande blanche ---"
p = user.products.find_by(id: 1098)
if p
  add_cond(p, colin, 1, "kg", 7.92)
else
  puts "  Introuvable"
end

# Vinaigre de vin (ID 1090) — 1.53€/l
puts ""
puts "--- Vinaigre de vin ---"
p = user.products.find_by(id: 1090)
if p
  add_cond(p, colin, 1, "l", 1.53)
else
  puts "  Introuvable"
end

puts ""

# ============================================================
# 3. RECALCUL EN CASCADE
# ============================================================
puts "=== RECALCUL ==="
user.recipes.each do |r|
  Recipes::Recalculator.call(r)
rescue => e
  # skip
end
puts "Recalcul terminé."
puts "Done."
