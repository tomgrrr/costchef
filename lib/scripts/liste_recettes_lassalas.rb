# encoding: utf-8
# Liste toutes les recettes en base pour Lassalas
# Colonnes : ID | Nom | Type | Coût/kg | Nb ingrédients | Statut coût

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")
abort "User introuvable" unless user

recipes = user.recipes.includes(:recipe_components).order(:name)

puts "=== RECETTES LASSALAS (#{recipes.count} total) ==="
puts "ID\tNom\tType\tCoût/kg\tNb ingrédients\tStatut"

recipes.each do |r|
  type    = r.sellable_as_component ? "composant" : "finale"
  cost    = r.cached_cost_per_kg.to_f.round(3)
  nb_ing  = r.recipe_components.size
  statut  = cost > 0 ? "ok" : "coût nul"

  puts [r.id, r.name, type, "#{cost} €/kg", nb_ing, statut].join("\t")
end

puts ""
puts "Total : #{recipes.count} recettes (#{recipes.where(sellable_as_component: false).count} finales, #{recipes.where(sellable_as_component: true).count} composants)"
