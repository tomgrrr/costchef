# encoding: utf-8
# Audit global — produits sans prix + recettes avec composants manquants

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")
abort "User introuvable" unless user

products = user.products.includes(:product_purchases).order("name ASC")

puts "=== PRODUITS SANS CONDITIONNEMENT ==="
sans_cond = products.select { |p| p.product_purchases.empty? }
sans_cond.each { |p| puts "  ID #{p.id} | #{p.name}" }
puts "  → #{sans_cond.count} produits sans conditionnement"
puts ""

puts "=== PRODUITS AVEC CONDITIONNEMENT MAIS SANS PRIX/KG ==="
avec_cond_sans_prix = products.select { |p| p.product_purchases.any? && (p.avg_price_per_kg.nil? || p.avg_price_per_kg == 0) }
avec_cond_sans_prix.each { |p| puts "  ID #{p.id} | #{p.name} | #{p.product_purchases.count} cond" }
puts "  → #{avec_cond_sans_prix.count} produits dans ce cas"
puts ""

puts "=== RECETTES AVEC COMPOSANTS SANS PRIX ==="
recipes = user.recipes.includes(recipe_components: :component).order("name ASC")
recipes_with_missing = []

recipes.each do |r|
  missing = r.recipe_components.select do |rc|
    if rc.component_type == "Product"
      p = rc.component
      p.nil? || p.avg_price_per_kg.nil? || p.avg_price_per_kg == 0
    elsif rc.component_type == "Recipe"
      sub = rc.component
      sub.nil? || sub.cached_cost_per_kg.nil? || sub.cached_cost_per_kg == 0
    end
  end
  next if missing.empty?
  recipes_with_missing << { recipe: r, missing: missing }
end

recipes_with_missing.each do |entry|
  r = entry[:recipe]
  puts "  Recette ID #{r.id} | #{r.name}"
  entry[:missing].each do |rc|
    comp = rc.component
    label = comp ? comp.name : "SUPPRIMÉ (#{rc.component_type} #{rc.component_id})"
    puts "    ❌ #{label}"
  end
end
puts "  → #{recipes_with_missing.count} recettes avec composants manquants"
puts ""

puts "=== RÉSUMÉ ==="
puts "Produits total         : #{products.count}"
puts "Sans conditionnement   : #{sans_cond.count}"
puts "Cond. sans prix/kg     : #{avec_cond_sans_prix.count}"
puts "Recettes incomplètes   : #{recipes_with_missing.count}"
