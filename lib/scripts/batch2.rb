# encoding: utf-8
# frozen_string_literal: true
# BATCH 2 : TPT, Sauce pizza, Jus de fruit, Vinaigrette, Vinaigrette balsamique

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

def upsert_sr!(user, name)
  r = user.recipes.find_or_initialize_by(name: name)
  r.sellable_as_component = true
  r.cooking_loss_percentage = 0
  RecipeComponent.where(parent_recipe_id: r.id).delete_all if r.persisted?
  r.save!
  r
end

def add!(r, p, q)
  r.recipe_components.create!(
    component: p,
    quantity_kg: q.to_f,
    quantity_unit: "kg"
  )
end

ActiveRecord::Base.transaction do

  # ── 6. TPT SOUS RECETTE ───────────────────────────
  # TPT = Tant Pour Tant (sucre glace + poudre amande)
  puts "\n6. TPT sous recette"
  r = upsert_sr!(user, "TPT sous recette")
  add!(r, find_product!(user, "Sucre glace"),                    6.0)
  add!(r, find_or_create_product!(user, "Poudre amande blanche"), 4.0)
  add!(r, find_product!(user, "Farine de bl"),                   2.0)
  add!(r, find_or_create_product!(user, "Levure"),               0.1)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # ── 7. SAUCE PIZZA ────────────────────────────────
  # Note : Sucre = 0.5 Kg (pas 500 — erreur source corrigee)
  puts "\n7. Sauce pizza"
  r = upsert_sr!(user, "Sauce pizza")
  add!(r, find_product!(user, "Beurre"),                   0.25)
  add!(r, find_product!(user, "Huile d'olive", "olive"),   0.25)
  add!(r, find_product!(user, "Oignons"),                  1.5)
  add!(r, find_product!(user, "Tomates"),                  4.0)
  add!(r, find_product!(user, "Sel"),                      0.2)
  add!(r, find_product!(user, "Poivre"),                   0.01)
  add!(r, find_product!(user, "Sucre semoule"),            0.5)
  add!(r, find_product!(user, "Origan"),                   0.01)
  add!(r, find_or_create_product!(user, "Concentre de tomates"),  0.6)
  roux = user.recipes.find_by!(name: "Roux")
  r.recipe_components.create!(component: roux, quantity_kg: 1.0, quantity_unit: "kg")
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # ── 8. JUS DE FRUIT SOUS RECETTE ─────────────────
  puts "\n8. Jus de fruit sous recette"
  r = upsert_sr!(user, "jus de fruit sous recette")
  add!(r, find_product!(user, "Framboise"),     1.0)
  add!(r, find_product!(user, "Sucre semoule"), 0.15)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # ── 9. VINAIGRETTE SOUS RECETTE ───────────────────
  puts "\n9. Vinaigrette sous recette"
  r = upsert_sr!(user, "Vinaigrette sous recette")
  add!(r, find_product!(user, "Huile tournesol"),              3.5)
  add!(r, find_product!(user, "Huile d'olive", "olive"),       0.5)
  add!(r, find_or_create_product!(user, "Vinaigre de vin"),    1.2)
  add!(r, find_or_create_product!(user, "Vinaigre balsamique"), 0.4)
  add!(r, find_or_create_product!(user, "Moutarde"),           1.0)
  add!(r, find_or_create_product!(user, "Persillade"),         0.01)
  add!(r, find_product!(user, "Sel"),                          0.1)
  add!(r, find_product!(user, "Poivre"),                       0.02)
  add!(r, find_or_create_product!(user, "Mayonnaise"),         0.2)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # ── 10. VINAIGRETTE BALSAMIQUE SOUS RECETTE ───────
  puts "\n10. Vinaigrette balsamique sous recette"
  r = upsert_sr!(user, "vinaigrette balsamique sous recette")
  add!(r, find_product!(user, "Huile tournesol"),               4.0)
  add!(r, find_or_create_product!(user, "Vinaigre balsamique"), 2.0)
  add!(r, find_or_create_product!(user, "Moutarde"),            0.4)
  add!(r, find_or_create_product!(user, "Mayonnaise"),          0.15)
  add!(r, find_product!(user, "Sel"),                           0.07)
  add!(r, find_product!(user, "Poivre"),                        0.01)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

end

puts "\nBatch 2 termine. Total recettes : #{user.recipes.count}"
