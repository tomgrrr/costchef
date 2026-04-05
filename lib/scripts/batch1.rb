# encoding: utf-8
# frozen_string_literal: true
# BATCH 1 : Roux, Gratin dauphinois, Purée, Poireaux, Mayonnaise

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

def find_or_create_product!(user, name, unit: "kg")
  p = user.products.where("LOWER(name) = ?", name.downcase).first
  unless p
    p = user.products.create!(name: name, base_unit: unit, avg_price_per_kg: 0)
    puts "   [CREE] #{name} (prix a renseigner)"
  end
  p
end

def find_product!(user, name)
  user.products.where("LOWER(name) = ?", name.downcase).first ||
  user.products.where("name ILIKE ?", "%#{name}%").first ||
  raise("PRODUIT INTROUVABLE : #{name}")
end

def upsert_subrecipe!(user, name)
  r = user.recipes.find_or_initialize_by(name: name)
  r.sellable_as_component = true
  r.cooking_loss_percentage = 0
  if r.persisted?
    RecipeComponent.where(parent_recipe_id: r.id).delete_all
  end
  r.save!
  r
end

def add!(recipe, product, qty_kg)
  recipe.recipe_components.create!(
    component: product,
    quantity_kg: qty_kg.to_f,
    quantity_unit: "kg"
  )
end

ActiveRecord::Base.transaction do

  # ── 1. ROUX ──────────────────────────────────────
  puts "\n1. Roux"
  r = upsert_subrecipe!(user, "Roux")
  add!(r, find_product!(user, "privilege margarine tourage pl"), 14.0)
  add!(r, find_product!(user, "Beurre"),                         10.0)
  add!(r, find_or_create_product!(user, "Beurre tracé"),          6.0)
  add!(r, find_product!(user, "Farine de blé T55"),              31.0)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # ── 2. GRATIN DAUPHINOIS ──────────────────────────
  puts "\n2. Gratin dauphinois"
  r = upsert_subrecipe!(user, "Gratin dauphinois")
  add!(r, find_product!(user, "PDT"),                            44.0)
  add!(r, find_product!(user, "Crème"),                          12.0)
  add!(r, find_product!(user, "Lait"),                           12.0)
  add!(r, find_product!(user, "Beurre"),                          0.5)
  add!(r, find_product!(user, "Sel"),                             0.43)
  add!(r, find_product!(user, "Poivre"),                          0.03)
  add!(r, find_or_create_product!(user, "Muscade"),               0.01)
  add!(r, find_product!(user, "AIL"),                             0.5)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # ── 3. PURÉE ──────────────────────────────────────
  puts "\n3. Purée"
  r = upsert_subrecipe!(user, "Purée")
  add!(r, find_product!(user, "Crème"),                           0.5)
  add!(r, find_product!(user, "Beurre"),                          0.15)
  add!(r, find_or_create_product!(user, "Poudre purée"),          0.4)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # ── 4. POIREAUX SOUS RECETTE ──────────────────────
  puts "\n4. Poireaux sous recette"
  r = upsert_subrecipe!(user, "Poireaux sous recette")
  add!(r, find_product!(user, "Poireaux"),                       50.0)
  add!(r, find_or_create_product!(user, "Beurre tracé"),          1.0)
  add!(r, find_product!(user, "Sel"),                             0.5)
  add!(r, find_product!(user, "Sucre semoule"),                   0.6)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # ── 5. MAYONNAISE SOUS RECETTE ────────────────────
  puts "\n5. Mayonnaise sous recette"
  r = upsert_subrecipe!(user, "mayonnaise sous recette")
  add!(r, find_product!(user, "Oeuf solide"),                     2.0)
  add!(r, find_or_create_product!(user, "Moutarde"),              1.0)
  add!(r, find_product!(user, "Sel"),                             0.1)
  add!(r, find_product!(user, "Poivre"),                          0.01)
  add!(r, find_or_create_product!(user, "Vinaigre"),              0.3)
  add!(r, find_product!(user, "Huile tournesol sye BI5L"),       12.5)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

end

puts "\nBatch 1 termine."
puts "Recettes creees : #{user.recipes.count}"
puts "Produits a prix 0 : #{user.products.where(avg_price_per_kg: 0).pluck(:name).join(', ')}"
