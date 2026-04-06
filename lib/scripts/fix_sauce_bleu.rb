# encoding: utf-8
# frozen_string_literal: true
# Corrige la Sauce feuilleté bleu :
# "cord. bleu dinde" (3 kg) → "Bleu d'Auvergne" (nouveau produit, 3 kg)
# Cause : search: "Bleu" avait matché "cord. bleu dinde" au lieu de créer Bleu d'Auvergne

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

sauce = user.recipes.find_by!("LOWER(name) LIKE ?", "%sauce feuilleté bleu%")
puts "Recette : #{sauce.name}"
puts "Composants actuels :"
sauce.recipe_components.includes(:component).each do |rc|
  puts "  #{rc.component.name} : #{rc.quantity_kg} kg"
end

ActiveRecord::Base.transaction do

  # Trouver le faux composant "cord. bleu dinde"
  faux = user.products.find_by("name ILIKE ?", "%cord%bleu%")
  raise "Faux produit 'cord. bleu dinde' introuvable" unless faux
  puts "\n[TROUVE] Faux produit : #{faux.name}"

  # Créer "Bleu d'Auvergne" s'il n'existe pas
  bleu = user.products.find_by("LOWER(name) = ?", "bleu d'auvergne") ||
         user.products.find_by("name ILIKE ?", "%Auvergne%") ||
         user.products.create!(name: "Bleu d'Auvergne", base_unit: "kg", avg_price_per_kg: 0)
  puts "[PRODUIT] Bleu d'Auvergne : #{bleu.name} (ID #{bleu.id})"

  # Rerattacher le RecipeComponent
  rc = sauce.recipe_components.find_by(component_type: "Product", component_id: faux.id)
  raise "Composant introuvable dans la recette" unless rc

  rc.update!(component_id: bleu.id)
  puts "[FIXE] cord. bleu dinde → Bleu d'Auvergne (#{rc.quantity_kg} kg)"

  # Recalculer
  Recipes::Recalculator.call(sauce)
  sauce.reload
  puts "\n[RECALCUL] #{sauce.name} → #{sauce.cached_cost_per_kg.round(2)} EUR/kg"

  puts "\nComposants corrigés :"
  sauce.recipe_components.includes(:component).each do |rc|
    puts "  #{rc.component.name} : #{rc.quantity_kg} kg"
  end

end
