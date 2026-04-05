# encoding: utf-8
# frozen_string_literal: true
# BATCH 3 : Pate sucree, Pate a pizza, Vinaigrette carottes, Carottes rapees, Frangipane

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

  # ── 11. PATE SUCREE ──────────────────────────────
  puts "\n11. Pate sucree"
  r = upsert_sr!(user, "Pate sucree")
  add_p!(r, find_product!(user, "Farine de bl"),                    30.0)
  add_p!(r, find_product!(user, "Beurre"),                          15.0)
  add_p!(r, find_product!(user, "Sucre glace"),                     14.5)
  add_p!(r, find_or_create_product!(user, "Fecule"),                 8.0)
  add_p!(r, find_or_create_product!(user, "Poudre amande grise"),    4.5)
  add_p!(r, find_product!(user, "Sel"),                              0.2)
  add_p!(r, find_product!(user, "Oeuf liquid", "Oeuf sol"),          9.0)
  add_p!(r, find_or_create_product!(user, "Vanille"),                0.1)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # ── 12. PATE A PIZZA ─────────────────────────────
  puts "\n12. Pate a pizza"
  r = upsert_sr!(user, "Pate a pizza")
  add_p!(r, find_product!(user, "Farine de bl"),                    50.0)
  add_p!(r, find_product!(user, "Sel"),                              1.0)
  add_p!(r, find_product!(user, "Sucre semoule"),                    2.5)
  add_p!(r, find_product!(user, "Oeuf sol"),                         9.0)
  add_p!(r, find_or_create_product!(user, "Levure"),                 2.5)
  add_p!(r, find_product!(user, "Lait"),                             6.0)
  add_p!(r, find_product!(user, "Huile d'olive", "olive"),           1.0)
  add_p!(r, find_product!(user, "Beurre"),                           7.0)
  add_p!(r, find_product!(user, "privilege margarine"),              6.0)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # ── 13. VINAIGRETTE CAROTTES RAPEES ──────────────
  puts "\n13. Vinaigrette carottes rapees sous recette"
  r = upsert_sr!(user, "vinaigrette carottes rapees sous recette")
  add_p!(r, find_product!(user, "Huile tournesol"),                  3.5)
  add_p!(r, find_product!(user, "Huile d'olive", "olive"),           0.5)
  add_p!(r, find_product!(user, "Vinaigre de vin"),                  2.2)
  add_p!(r, find_product!(user, "Vinaigre balsamique"),              0.6)
  add_p!(r, find_product!(user, "Moutarde"),                         1.0)
  add_p!(r, find_or_create_product!(user, "Persillade"),             0.02)
  add_p!(r, find_product!(user, "Sel"),                              0.2)
  add_p!(r, find_product!(user, "Poivre"),                           0.02)
  add_p!(r, find_product!(user, "Mayonnaise"),                       0.3)
  add_p!(r, find_product!(user, "Citron"),                           0.6)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # ── 14. CAROTTES RAPEES SOUS RECETTE ─────────────
  # Depends on vinaigrette carottes (created just above)
  puts "\n14. Carottes rapees sous recette"
  r = upsert_sr!(user, "Carottes rapees sous recette")
  add_p!(r,  find_product!(user, "Carotte"),                         1.3)
  add_sr!(r, find_subrecipe!(user, "vinaigrette carottes rapees sous recette"), 0.25)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # ── 15. FRANGIPANE ───────────────────────────────
  # Depends on TPT (Batch 2)
  puts "\n15. Frangipane"
  r = upsert_sr!(user, "Frangipane")
  add_sr!(r, find_subrecipe!(user, "TPT sous recette"),              4.2)
  add_p!(r,  user.products.find_by!("name = ?", "Blanc"),            2.0)  # Blanc d'oeuf (exact match)
  add_p!(r,  find_product!(user, "Beurre"),                          1.5)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

end

puts "\nBatch 3 termine. Total sous-recettes : #{user.recipes.where(sellable_as_component: true).count}"
