# encoding: utf-8
# Fusion Oignons → Oignons entier

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")

old_p = user.products.where("name ILIKE ?", "oignons").first
new_p = user.products.where("name ILIKE ?", "oignons entier%").first

puts "Fusion : [#{old_p&.name}] (ID #{old_p&.id}) → [#{new_p&.name}] (ID #{new_p&.id})"

if old_p.nil? || new_p.nil?
  puts "ERREUR : un des deux produits introuvable"
  exit
end

puts "Avant : #{old_p.recipe_components.count} composant(s) sur [#{old_p.name}]"

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
puts "Apres : #{old_p.recipe_components.count} composant(s) restant(s)"

if old_p.recipe_components.count == 0
  old_p.delete
  puts "OK supprime : #{old_p.name} (ID #{old_p.id})"
else
  puts "ERREUR : composants encore presents, suppression annulee"
end

puts "Recalcul..."
Recalculations::Dispatcher.full_product_recalculation(new_p)
puts "Termine."
