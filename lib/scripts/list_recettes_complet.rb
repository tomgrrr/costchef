# encoding: utf-8
# Liste complète de toutes les recettes — pour rapprochement avec classement ventes

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")
abort "User introuvable" unless user

puts "=== RECETTES FINALES (sellable_as_component: false) ==="
user.recipes.where(sellable_as_component: false).order(:name).each do |r|
  cost = r.cached_cost_per_kg.to_f.round(3)
  puts "#{r.id}\t#{r.name}\t#{cost}"
end

puts ""
puts "=== SOUS-RECETTES / SAUCES (sellable_as_component: true) ==="
user.recipes.where(sellable_as_component: true).order(:name).each do |r|
  puts "#{r.id}\t#{r.name}"
end

puts ""
total = user.recipes.count
puts "Total : #{total} recettes"
