# encoding: utf-8
# frozen_string_literal: true
# BATCH 5 : Pâte à pompe, Sauce feuilleté bleu, Béchamel feuilleté jambon,
#            Sauce ris de veau louche, Beurre escargot, Pâte à pâté en croûte
#
# PRÉ-REQUIS : fix_beurre.rb doit avoir été exécuté (Beurre → Beurre doux)

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

# Garde-fou : vérifie que fix_beurre a bien tourné
unless user.products.find_by("LOWER(name) = ?", "beurre doux")
  raise "⛔  Lancez d'abord fix_beurre.rb — produit 'Beurre doux' introuvable en base"
end

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

  # ── 20. PÂTE À POMPE ─────────────────────────────────────────────────
  puts "\n20. Pâte à pompe"
  r = upsert_sr!(user, "Pâte à pompe")
  add_p!(r, find_or_create_product!(user, "Farine de blé",      search: "Farine de bl"),  50.0)
  add_p!(r, find_or_create_product!(user, "Beurre motte",       search: "Beurre motte"),  12.0)
  add_p!(r, find_or_create_product!(user, "Beurre tracé",       search: "Beurre trac"),    7.0)
  add_p!(r, find_or_create_product!(user, "Margarine",          search: "margarine"),       6.0)
  add_p!(r, find_or_create_product!(user, "Sucre semoule",      search: "Sucre semoule"),  16.0)
  add_p!(r, find_or_create_product!(user, "Sel"),                                           0.3)
  add_p!(r, find_or_create_product!(user, "Huile de tournesol", search: "tournesol"),       2.5)
  add_p!(r, find_or_create_product!(user, "Eau"),                                          10.0)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # ── 21. SAUCE FEUILLETÉ BLEU ──────────────────────────────────────────
  puts "\n21. Sauce feuilleté bleu"
  r = upsert_sr!(user, "Sauce feuilleté bleu")
  add_p!(r, find_or_create_product!(user, "Lait"),                                         3.0)
  add_p!(r, find_or_create_product!(user, "Crème",              search: "Crème"),           2.0)
  add_p!(r, find_or_create_product!(user, "Bleu d'Auvergne",   search: "Bleu"),             3.0)
  add_p!(r, find_or_create_product!(user, "Noix"),                                          0.25)
  add_sr!(r, find_subrecipe!(user, "Roux"),                                                 1.7)
  add_p!(r, find_or_create_product!(user, "Poivre"),                                       0.01)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # ── 22. BÉCHAMEL FEUILLETÉ JAMBON ────────────────────────────────────
  # Picardan = Macardan (note ODS confirmée)
  puts "\n22. Béchamel feuilleté jambon"
  r = upsert_sr!(user, "Béchamel feuilleté jambon")
  add_p!(r, find_or_create_product!(user, "Lait"),                                        12.0)
  add_p!(r, find_or_create_product!(user, "Crème",              search: "Crème"),          8.0)
  add_sr!(r, find_subrecipe!(user, "Roux"),                                                4.5)
  add_p!(r, find_or_create_product!(user, "Macardan",           search: "macardan"),       1.0)
  add_p!(r, find_or_create_product!(user, "Sel"),                                          0.2)
  add_p!(r, find_or_create_product!(user, "Poivre"),                                      0.01)
  add_p!(r, find_or_create_product!(user, "Muscade"),                                     0.05)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # ── 23. SAUCE RIS DE VEAU LOUCHE ─────────────────────────────────────
  # "Sac cuisson" (4 pièces) = consommable non pricé → ignoré volontairement
  puts "\n23. Sauce ris de veau louche"
  r = upsert_sr!(user, "Sauce ris de veau louche")
  add_p!(r, find_or_create_product!(user, "Beurre doux",        search: "Beurre doux"),    1.0)
  add_p!(r, find_or_create_product!(user, "Echalotte",         search: "Echalot"),         1.0)
  add_p!(r, find_or_create_product!(user, "Morilles"),                                     4.0)
  add_p!(r, find_or_create_product!(user, "Ris de veau",        search: "Ris de veau"),   40.0)
  add_p!(r, find_or_create_product!(user, "Porto",              unit: "l"),                2.0)
  add_sr!(r, find_subrecipe!(user, "Sauce pizza"),                                         2.0)
  add_p!(r, find_or_create_product!(user, "Crème",              search: "Crème"),         28.0)
  add_p!(r, find_or_create_product!(user, "Lait"),                                         2.0)
  add_p!(r, find_or_create_product!(user, "Crème épaisse",      search: "paisse"),         2.0)
  add_p!(r, find_or_create_product!(user, "Sel"),                                          0.52)
  add_p!(r, find_or_create_product!(user, "Poivre"),                                      0.03)
  add_sr!(r, find_subrecipe!(user, "Roux"),                                                4.0)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # ── 24. BEURRE ESCARGOT ───────────────────────────────────────────────
  puts "\n24. Beurre escargot"
  r = upsert_sr!(user, "Beurre escargot")
  add_p!(r, find_or_create_product!(user, "Persil",             search: "Persil"),         0.75)
  add_p!(r, find_or_create_product!(user, "Echalotte",         search: "Echalot"),         0.12)
  add_p!(r, find_or_create_product!(user, "Ail"),                                          0.12)
  add_p!(r, find_or_create_product!(user, "Sel"),                                          0.15)
  add_p!(r, find_or_create_product!(user, "Poivre"),                                      0.01)
  add_p!(r, find_or_create_product!(user, "Thym"),                                        0.006)
  add_p!(r, find_or_create_product!(user, "Muscade"),                                     0.006)
  add_p!(r, find_or_create_product!(user, "Noix"),                                         0.2)
  add_p!(r, find_or_create_product!(user, "Anchois"),                                      0.15)
  add_p!(r, find_or_create_product!(user, "Ricard",             unit: "l"),                0.1)
  add_p!(r, find_or_create_product!(user, "Beurre doux",        search: "Beurre doux"),    6.0)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  # ── 25. PÂTE À PÂTÉ EN CROÛTE ────────────────────────────────────────
  puts "\n25. Pâte à pâté en croûte"
  r = upsert_sr!(user, "Pâte à pâté en croûte")
  add_p!(r, find_or_create_product!(user, "Farine de blé",      search: "Farine de bl"),  42.0)
  add_p!(r, find_or_create_product!(user, "Sel"),                                           0.84)
  add_p!(r, find_or_create_product!(user, "Sucre semoule",      search: "Sucre semoule"),  0.84)
  add_p!(r, find_or_create_product!(user, "Beurre doux",        search: "Beurre doux"),    3.5)
  add_p!(r, find_or_create_product!(user, "Beurre tracé",       search: "Beurre trac"),   14.0)
  add_p!(r, find_or_create_product!(user, "Oeuf liquide entier",search: "Oeuf liquide"),   7.0)
  add_p!(r, find_or_create_product!(user, "Cognac",             unit: "l"),                 7.0)
  Recipes::Recalculator.call(r)
  puts "   #{r.recipe_components.count} composants | #{r.reload.cached_cost_per_kg.round(2)} EUR/kg"

  puts "\nBatch 5 terminé. Total sous-recettes : #{user.recipes.where(sellable_as_component: true).count}"

end
