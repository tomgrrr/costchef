# encoding: utf-8
# frozen_string_literal: true
# BATCH 4 : Legumes SR, Sauce quiche, Bolognaise SR, Sauce spaghetti SR

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

def find_or_create_product!(user, name, unit: "kg")
  p = user.products.where("LOWER(name) = ?", name.downcase).first
  unless p
    p = user.products.create!(name: name, base_unit: unit, avg_price_per_kg: 0)
    puts "   [CREE] #{name}"
  end
  p
end

def find_product!(user, *candidates)
  candidates.each do |name|
    p = user.products.where("name ILIKE ?", "%#{name}%").first
    return p if p
  end
  raise "INTROUVABLE : #{candidates.join(' / ')}"
end

def find_subrecipe!(user, name)
  user.recipes.where("LOWER(name) = ?", name.downcase).first ||
    raise("SOUS-RECETTE INTROUVABLE : #{name}")
end

def upsert_sr!(user, name)
  r = user.recipes.find_or_initialize_by(name: name)
  r.sellable_as_component = true
  r.cooking_loss_percentage = 0
  RecipeComponent.where(parent_recipe_id: r.id).delete_all if r.persisted?
  r.save!
  r
end

def add_p!(r, product, qty_kg)
  r.recipe_components.create!(component: product, quantity_kg: qty_kg.to_f, quantity_unit: "kg")
end

def add_sr!(r, subrecipe, qty_kg)
  r.recipe_components.create!(component: subrecipe, quantity_kg: qty_kg.to_f, quantity_unit: "kg")
end

ActiveRecord::Base.transaction do

  # 16. Legumes sous recette
  puts "\n16. Legumes sous recette"
  r = upsert_sr!(user, "Légumes sous recette")
  add_p!(r, find_product!(user, "Julienne", "julienne leg"),          5.0)
  add_p!(r, find_product!(user, "Gruyère", "Gruyere", "gruyere"),    1.0)
  add_p!(r, find_product!(user, "Sel"),                               0.03)
  add_p!(r, find_product!(user, "Poivre"),                            0.03)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # 17. Sauce quiche
  puts "\n17. Sauce quiche"
  r = upsert_sr!(user, "Sauce quiche")
  add_p!(r, find_product!(user, "Lait"),                              10.0)
  add_p!(r, find_product!(user, "Crème", "Creme"),                    8.0)
  add_p!(r, find_or_create_product!(user, "Crème épaisse"),           2.0)
  add_sr!(r, find_subrecipe!(user, "Roux"),                           1.3)
  add_p!(r, find_product!(user, "Sel"),                               0.1)
  add_p!(r, find_product!(user, "Poivre"),                            0.01)
  add_p!(r, find_product!(user, "Muscade"),                           0.05)
  add_p!(r, find_product!(user, "Oeuf solide", "Oeuf coquille"),      5.0) # 100 pièces x 50g
  add_p!(r, find_product!(user, "Oeuf liquide", "Oeuf entier"),       4.0)
  add_p!(r, find_or_create_product!(user, "Jaune d'oeuf"),            1.0)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # 18. Bolognaise sous recette
  puts "\n18. Bolognaise sous recette"
  r = upsert_sr!(user, "Bolognaise sous recette")
  add_p!(r, find_product!(user, "Huile d'olive", "Huile olive"),      3.0)
  add_p!(r, find_product!(user, "Oignon", "oignons"),                 10.0) # oignons rondelles surgelés
  add_p!(r, find_product!(user, "Carotte"),                           8.0)  # carottes rapées brutes
  add_p!(r, find_or_create_product!(user, "Eau"),                     16.0)
  add_p!(r, find_or_create_product!(user, "Égrainés de boeuf"),       60.0)
  add_p!(r, find_product!(user, "Vin blanc"),                         3.0)
  add_p!(r, find_product!(user, "Concentre", "Concentré"),            10.0)
  add_p!(r, find_or_create_product!(user, "Gustoza"),                 9.0)
  add_p!(r, find_product!(user, "fond"),                              1.5)
  add_p!(r, find_product!(user, "Sel"),                               0.8)
  add_p!(r, find_product!(user, "Poivre"),                            0.04)
  add_p!(r, find_or_create_product!(user, "Piment"),                  0.01)
  add_p!(r, find_or_create_product!(user, "Chocolat"),                0.2)
  add_p!(r, find_product!(user, "Persil"),                            1.5)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # 19. Sauce spaghetti sous recette
  puts "\n19. Sauce spaghetti sous recette"
  r = upsert_sr!(user, "Sauce spaghetti sous recette")
  add_p!(r, find_or_create_product!(user, "Eau"),                     1.0)
  add_p!(r, find_product!(user, "Beurre"),                            0.75)
  add_p!(r, find_product!(user, "Sel"),                               0.03)
  add_p!(r, find_product!(user, "Poivre"),                            0.005)
  add_sr!(r, find_subrecipe!(user, "Sauce pizza"),                    4.5)
  add_p!(r, find_product!(user, "Concentre", "Concentré"),            0.1)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  puts "\nBatch 4 termine. Total sous-recettes : #{user.recipes.where(sellable_as_component: true).count}"

end
