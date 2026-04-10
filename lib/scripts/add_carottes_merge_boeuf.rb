# encoding: utf-8

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")

# ============================================================
# 1. CAROTTES — ajout conditionnement Jallet 20kg / 28€
# ============================================================
puts "=== CAROTTES ==="
carotte = user.products.where("name ILIKE ?", "carotte%").to_a
puts "Produits trouvés :"
carotte.each { |p| puts "  ID #{p.id} | #{p.name} | base_unit: #{p.base_unit}" }

c = user.products.where("name ILIKE ?", "carotte%").first
puts "\nProduit retenu : ID #{c.id} — #{c.name}"

supplier = user.suppliers.where("name ILIKE ?", "jallet").first
if supplier.nil?
  supplier = user.suppliers.create!(name: "Jallet")
  puts "Fournisseur Jallet créé (ID #{supplier.id})"
else
  puts "Fournisseur Jallet trouvé (ID #{supplier.id})"
end

pp = ProductPurchase.create!(
  product: c,
  supplier: supplier,
  package_quantity: 20,
  package_unit: "kg",
  package_price: 28.0
)
puts "Conditionnement créé : ID #{pp.id} | 20 kg | 28.00€"

Products::AvgPriceRecalculator.call(c)
puts "avg_price_per_kg après : #{c.reload.avg_price_per_kg}€/kg"

# ============================================================
# 2. FUSION — Égrainés de bœuf (vide) → Egrene boeuf (pricé)
# ============================================================
puts ""
puts "=== FUSION BOEUF ==="

old_p = user.products.where("name ILIKE ?", "%grainé%").to_a
new_p = user.products.where("name ILIKE ?", "%grene%boeuf%").to_a + user.products.where("name ILIKE ?", "%boeuf%grene%").to_a

puts "Candidats 'vide' (Égrainés) :"
old_p.each { |p| puts "  ID #{p.id} | #{p.name} | conditionnements: #{p.product_purchases.count}" }

puts "Candidats 'pricé' (Egrene) :"
new_p.each { |p| puts "  ID #{p.id} | #{p.name} | conditionnements: #{p.product_purchases.count}" }

# Prendre celui sans conditionnement comme "old", celui avec conditionnements comme "new"
all_candidates = (old_p + new_p).uniq { |p| p.id }
keeper = all_candidates.max_by { |p| p.product_purchases.count }
to_delete = all_candidates.select { |p| p.id != keeper.id && p.product_purchases.count == 0 }

puts ""
puts "Keeper : ID #{keeper.id} — #{keeper.name} (#{keeper.product_purchases.count} conditionnements)"
to_delete.each do |old|
  puts "À fusionner/supprimer : ID #{old.id} — #{old.name}"

  rc_list = RecipeComponent.where(component_type: "Product", component_id: old.id)
  puts "  #{rc_list.count} recipe_components à migrer"

  rc_list.each do |rc|
    existing = RecipeComponent.find_by(parent_recipe_id: rc.parent_recipe_id, component_type: "Product", component_id: keeper.id)
    if existing
      existing.update!(quantity_kg: existing.quantity_kg + rc.quantity_kg)
      rc.destroy!
      puts "    Fusionné dans RC existant (recette #{rc.parent_recipe_id})"
    else
      rc.update!(component_id: keeper.id)
      puts "    Rebranché → #{keeper.name} (recette #{rc.parent_recipe_id})"
    end
  end

  old.delete
  puts "  Supprimé (ID #{old.id})"
end

puts ""
puts "Recalcul recettes de #{keeper.name}..."
Recalculations::Dispatcher.full_product_recalculation(keeper) rescue nil
puts "Done."
