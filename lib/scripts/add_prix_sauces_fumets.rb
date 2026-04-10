# encoding: utf-8

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")
colin = user.suppliers.where("name ILIKE ?", "colin").first_or_create!(name: "Colin")

def merge_product(old_p, new_p, label)
  puts "  #{label} : #{old_p.name} (#{old_p.product_purchases.count} cond) → #{new_p.name} (#{new_p.product_purchases.count} cond)"
  rc_list = RecipeComponent.where(component_type: "Product", component_id: old_p.id)
  puts "  #{rc_list.count} recipe_component(s) à migrer"
  rc_list.each do |rc|
    existing = RecipeComponent.find_by(parent_recipe_id: rc.parent_recipe_id, component_type: "Product", component_id: new_p.id)
    if existing
      existing.update!(quantity_kg: existing.quantity_kg + rc.quantity_kg)
      rc.destroy!
    else
      rc.update!(component_id: new_p.id)
    end
  end
  old_p.delete
  puts "  Supprimé : #{old_p.name}"
end

def add_cond(product, supplier, qty, unit, price, label)
  existing = product.product_purchases.find_by(supplier: supplier, package_quantity: qty, package_unit: unit)
  if existing
    puts "  #{label} : conditionnement déjà existant — skip"
  else
    pp = ProductPurchase.create!(product: product, supplier: supplier, package_quantity: qty, package_unit: unit, package_price: price)
    puts "  #{label} : conditionnement créé (ID #{pp.id}) | #{qty}#{unit} | #{price}€"
  end
  Products::AvgPriceRecalculator.call(product)
  puts "  avg_price_per_kg : #{product.reload.avg_price_per_kg}€/kg"
end

# ============================================================
# 1. FUSIONS — doublons 0 cond → produit pricé existant
# ============================================================
puts "=== FUSIONS ==="

# sauce morille → Sauce aux morilles
old = user.products.where("name = ?", "sauce morille").first
new_p = user.products.where("name ILIKE ?", "sauce aux morilles").first
merge_product(old, new_p, "sauce morille → Sauce aux morilles") if old && new_p

# sauce ecrevisse → Sauce écrevisse
old = user.products.where("name = ?", "sauce ecrevisse").first
new_p = user.products.where("name ILIKE ?", "sauce écrevisse%").where("name NOT ILIKE ?", "sauce aux%").first
merge_product(old, new_p, "sauce ecrevisse → Sauce écrevisse") if old && new_p

# sauce champignon → Sauce aux champignons
old = user.products.where("name = ?", "sauce champignon").first
new_p = user.products.where("name ILIKE ?", "sauce aux champignons").first
merge_product(old, new_p, "sauce champignon → Sauce aux champignons") if old && new_p

# fumet homard → Fumet de homard
old = user.products.where("name = ?", "fumet homard").first
new_p = user.products.where("name ILIKE ?", "fumet de homard").first
merge_product(old, new_p, "fumet homard → Fumet de homard") if old && new_p

# fumet crustace → Fumet de crustacés
old = user.products.where("name = ?", "fumet crustace").first
new_p = user.products.where("name ILIKE ?", "fumet de crustacés").first
merge_product(old, new_p, "fumet crustace → Fumet de crustacés") if old && new_p

puts ""

# ============================================================
# 2. CONDITIONNEMENTS — produits sans prix
# ============================================================
puts "=== CONDITIONNEMENTS ==="

# sauce homard → Sauce aux crustacés Colin 1kg 45.95€
p = user.products.where("name ILIKE ?", "sauce homard").first
add_cond(p, colin, 1, "kg", 45.95, "sauce homard") if p

# Fumet de crustacés → Sauce aux crustacés Colin 1kg 45.95€
p = user.products.where("name ILIKE ?", "fumet de crustacés").first
add_cond(p, colin, 1, "kg", 45.95, "Fumet de crustacés") if p

# fumet ecrevisse → Jus de langoustine en pâte Colin 1kg 29.35€
p = user.products.where("name = ?", "fumet ecrevisse").first
add_cond(p, colin, 1, "kg", 29.35, "fumet ecrevisse") if p

# fumet st jacques → Sauce aux st jacques Colin 1kg 34.79€
p = user.products.where("name = ?", "fumet st jacques").first
add_cond(p, colin, 1, "kg", 34.79, "fumet st jacques") if p

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
puts ""
puts "Done."
