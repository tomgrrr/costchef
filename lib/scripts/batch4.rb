# encoding: utf-8
# frozen_string_literal: true
# BATCH 4 : Legumes SR, Sauce quiche, Bolognaise SR, Sauce spaghetti SR

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

# Cherche d'abord par nom exact (insensible casse), puis par ILIKE partiel, puis cree
def find_or_create_product!(user, name, search: nil, unit: "kg")
  term = search || name
  p = user.products.where("LOWER(name) = ?", term.downcase).first
  p ||= user.products.where("name ILIKE ?", "%#{term}%").first
  unless p
    p = user.products.create!(name: name, base_unit: unit, avg_price_per_kg: 0)
    puts "   [CREE] #{name}"
  end
  p
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
  add_p!(r, find_or_create_product!(user, "Julienne de légumes surgelés", search: "Julienne"),  5.0)
  add_p!(r, find_or_create_product!(user, "Gruyère",   search: "Gruy"),                         1.0)
  add_p!(r, find_or_create_product!(user, "Sel"),                                                0.03)
  add_p!(r, find_or_create_product!(user, "Poivre"),                                             0.03)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # 17. Sauce quiche
  puts "\n17. Sauce quiche"
  r = upsert_sr!(user, "Sauce quiche")
  add_p!(r, find_or_create_product!(user, "Lait"),                                               10.0)
  add_p!(r, find_or_create_product!(user, "Crème",     search: "Crème"),                         8.0)
  add_p!(r, find_or_create_product!(user, "Crème épaisse"),                                      2.0)
  add_sr!(r, find_subrecipe!(user, "Roux"),                                                      1.3)
  add_p!(r, find_or_create_product!(user, "Sel"),                                                0.1)
  add_p!(r, find_or_create_product!(user, "Poivre"),                                             0.01)
  add_p!(r, find_or_create_product!(user, "Muscade"),                                            0.05)
  add_p!(r, find_or_create_product!(user, "Oeuf solide", search: "Oeuf solid"),                  5.0) # 100 pieces x 50g
  add_p!(r, find_or_create_product!(user, "Oeuf liquide entier", search: "Oeuf liquide"),        4.0)
  add_p!(r, find_or_create_product!(user, "Jaune",        search: "Jaune"),                      1.0) # Jaune d'oeuf
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # 18. Bolognaise sous recette
  puts "\n18. Bolognaise sous recette"
  r = upsert_sr!(user, "Bolognaise sous recette")
  add_p!(r, find_or_create_product!(user, "Huile d'olive vierge extra", search: "Huile d'oliv"), 3.0)
  add_p!(r, find_or_create_product!(user, "Oignons",   search: "Oignon"),                        10.0)
  add_p!(r, find_or_create_product!(user, "Carotte"),                                             8.0)
  add_p!(r, find_or_create_product!(user, "Eau"),                                                 16.0)
  add_p!(r, find_or_create_product!(user, "Egrene", search: "grene"),                            60.0) # Égrainé de boeuf
  add_p!(r, find_or_create_product!(user, "Vin blanc",  search: "Vin blanc"),                    3.0)
  add_p!(r, find_or_create_product!(user, "Concentre de tomates", search: "Concentr"),           10.0)
  add_p!(r, find_or_create_product!(user, "Gustoza"),                                             9.0)
  add_p!(r, find_or_create_product!(user, "Fond de veau", search: "fond"),                       1.5)
  add_p!(r, find_or_create_product!(user, "Sel"),                                                 0.8)
  add_p!(r, find_or_create_product!(user, "Poivre"),                                             0.04)
  add_p!(r, find_or_create_product!(user, "Piment"),                                             0.01)
  add_p!(r, find_or_create_product!(user, "Chocolat"),                                           0.2)
  add_p!(r, find_or_create_product!(user, "Persil",    search: "Persil"),                        1.5)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # 19. Sauce spaghetti sous recette
  puts "\n19. Sauce spaghetti sous recette"
  r = upsert_sr!(user, "Sauce spaghetti sous recette")
  add_p!(r, find_or_create_product!(user, "Eau"),                                                 1.0)
  add_p!(r, find_or_create_product!(user, "Beurre"),                                              0.75)
  add_p!(r, find_or_create_product!(user, "Sel"),                                                 0.03)
  add_p!(r, find_or_create_product!(user, "Poivre"),                                             0.005)
  add_sr!(r, find_subrecipe!(user, "Sauce pizza"),                                               4.5)
  add_p!(r, find_or_create_product!(user, "Concentre de tomates", search: "Concentr"),           0.1)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  puts "\nBatch 4 termine. Total sous-recettes : #{user.recipes.where(sellable_as_component: true).count}"

end
