# encoding: utf-8
# Fusion Ail (900) → Ail entier (1139)

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")

old_p = user.products.find(900)
new_p = user.products.find(1139)

puts "Avant migration : #{old_p.recipe_components.count} composant(s) sur [#{old_p.name}]"

old_p.recipe_components.each do |rc|
  existing = RecipeComponent.find_by(parent_recipe_id: rc.parent_recipe_id, component_type: "Product", component_id: new_p.id)
  if existing
    existing.update!(quantity_kg: existing.quantity_kg + rc.quantity_kg)
    rc.destroy!
    puts "  merge quantites dans #{rc.parent_recipe&.name}"
  else
    rc.update!(component_id: new_p.id)
    puts "  rebranche #{rc.parent_recipe&.name}"
  end
end

old_p.reload
puts "Apres migration : #{old_p.recipe_components.count} composant(s) restant(s)"

# Supprimer via delete (bypass callbacks) si destroy bloque
if old_p.recipe_components.count == 0
  old_p.delete
  puts "OK supprime : Ail (ID 900)"
else
  puts "ERREUR : composants encore presents, suppression annulee"
end
