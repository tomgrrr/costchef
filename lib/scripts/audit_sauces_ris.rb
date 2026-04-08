# encoding: utf-8
user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

["Sauce Feuilleté ris de veau", "Sauce ris de veau louche"].each do |name|
  r = user.recipes.find_by("name ILIKE ?", name)
  unless r
    puts "INTROUVABLE: #{name}"
    next
  end

  puts "\n#{'='*60}"
  puts "#{r.name} (ID #{r.id})"
  puts "  Sous-recette: #{r.sellable_as_component?} | Poids: #{r.cached_total_weight} kg | Coût/kg: #{r.cached_cost_per_kg} €"
  puts "  Ingrédients:"
  r.recipe_components.includes(:component).each do |rc|
    type = rc.recipe_component? ? "[SR]" : "[P] "
    puts "    #{type} #{rc.component.name.ljust(35)} #{rc.quantity_kg.to_f} kg"
  end
end
