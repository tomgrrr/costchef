# encoding: utf-8

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")
colin = user.suppliers.where("name ILIKE ?", "colin").first_or_create!(name: "Colin")

def merge_product(old_p, new_p)
  return puts "  SKIP — même produit" if old_p.id == new_p.id
  rc_list = RecipeComponent.where(component_type: "Product", component_id: old_p.id)
  puts "  #{rc_list.count} RC à migrer"
  rc_list.each do |rc|
    existing = RecipeComponent.find_by(parent_recipe_id: rc.parent_recipe_id, component_type: "Product", component_id: new_p.id)
    if existing
      existing.update!(quantity_kg: existing.quantity_kg + rc.quantity_kg)
      rc.destroy!
    else
      rc.update!(component_id: new_p.id)
    end
    puts "    → rebranché recette #{rc.parent_recipe_id}"
  end
  old_p.delete
  puts "  Supprimé : #{old_p.name} (ID #{old_p.id})"
end

def add_cond(product, supplier, qty, unit, price)
  existing = product.product_purchases.find_by(supplier: supplier, package_quantity: qty, package_unit: unit)
  return puts "  Conditionnement déjà existant — skip" if existing
  pp = ProductPurchase.create!(product: product, supplier: supplier, package_quantity: qty, package_unit: unit, package_price: price)
  Products::AvgPriceRecalculator.call(product)
  puts "  Créé : #{qty}#{unit} #{price}€ → avg #{product.reload.avg_price_per_kg}€/kg"
end

# Chaque entrée : [old_name_ilike, new_name_ilike, prix_fallback, unité_fallback]
# Si le produit "new" n'existe pas → on ajoute le conditionnement sur "old" et on ne supprime pas
pairs = [
  ["cremant",              "crémant bourgogne",      15.68, "l"],
  ["fécule",               "fécules pdt",             3.85, "kg"],
  ["fromage blanc",        "from. blanc",             3.35, "kg"],
  ["gustoza",              "sauce tomate (gustosa)", 13.94, "kg"],
  ["nappage",              "covergel nappage",        3.56, "kg"],
  ["quenelles de brochet", "quenelle brochet",        9.69, "kg"],
  ["farine de gruau",      "gruau",                   1.07, "kg"],
  ["brisure de nougat",    "brisure nougat",         31.75, "kg"],
  ["chocolat",             "chocolat noir",          18.78, "kg"],
  ["poudre amande grise",  "poudre amande grise",     9.22, "kg"],
  ["pulpe echalote",       "pulpe échalote",          3.59, "kg"],
]

pairs.each do |old_name, new_name, prix, unit|
  puts ""
  puts "=== #{old_name} → #{new_name} ==="

  old_p = user.products.where("name ILIKE ?", old_name).first
  new_p = user.products.where("name ILIKE ?", new_name).where.not(id: old_p&.id).first

  unless old_p
    puts "  Produit source introuvable — skip"
    next
  end

  puts "  Source : ID #{old_p.id} — #{old_p.name} (#{old_p.product_purchases.count} cond)"

  if new_p
    puts "  Cible  : ID #{new_p.id} — #{new_p.name} (#{new_p.product_purchases.count} cond, #{new_p.avg_price_per_kg}€/kg)"
    if new_p.product_purchases.empty?
      puts "  La cible n'a pas de conditionnement → ajout prix ODS"
      add_cond(new_p, colin, 1, unit, prix)
    end
    merge_product(old_p, new_p)
  else
    puts "  Cible introuvable → ajout conditionnement direct sur source"
    add_cond(old_p, colin, 1, unit, prix)
  end
end

puts ""
puts "=== RECALCUL ==="
user.recipes.each do |r|
  Recipes::Recalculator.call(r)
rescue => e
  # skip
end
puts "Recalcul terminé."
puts "Done."
