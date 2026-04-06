# encoding: utf-8
# frozen_string_literal: true
user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

puts "=" * 70
puts "RECAP SOUS-RECETTES - #{user.recipes.where(sellable_as_component: true).count} recettes"
puts "=" * 70

user.recipes.where(sellable_as_component: true).order(:name).each do |r|
  puts "\n#{r.name}"
  puts "  Poids brut  : #{r.cached_raw_weight.round(3)} kg" if r.cached_raw_weight > 0
  puts "  Poids final : #{r.cached_total_weight.round(3)} kg" if r.cached_total_weight > 0
  puts "  Cout total  : #{r.cached_total_cost.round(2)} EUR"
  puts "  Cout/kg     : #{r.cached_cost_per_kg.round(2)} EUR/kg"
  puts "  Composants  :"
  r.recipe_components.each do |rc|
    name = rc.component.name rescue "?"
    type = rc.component_type == "Recipe" ? "[SR]" : "[P] "
    puts "    #{type} #{name} : #{rc.quantity_kg} kg"
  end
end
