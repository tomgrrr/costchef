# encoding: utf-8
user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")

puts "=== RECETTES (sellable_as_component: false) ==="
user.recipes.where(sellable_as_component: false).order(:name).each do |r|
  puts "#{r.id}\t#{r.name}\t#{r.unit_cost.to_f.round(2)}€"
end

puts ""
puts "=== SOUS-RECETTES (sellable_as_component: true) ==="
user.recipes.where(sellable_as_component: true).order(:name).each do |r|
  puts "#{r.id}\t#{r.name}"
end
