# encoding: utf-8
# Script d'import des 21 nouvelles recettes feuilletés
# Prérequis : avoir exécuté delete_feuilletes.rb

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")
abort "User not found" unless user

PATE_FEUILLETEE_ID = 198
WARNINGS = []
CREATED  = []

# ─────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────

def find_component(user, search_term)
  p = user.products.where("name ILIKE ?", "%#{search_term}%").first
  return ["Product", p.id] if p

  r = user.recipes.where("name ILIKE ?", "%#{search_term}%").first
  return ["Recipe", r.id] if r

  nil
end

def add_ingredient(recipe, user, search_term, qty_kg, note: nil)
  result = find_component(user, search_term)
  unless result
    msg = "  ⚠️  INTROUVABLE '#{search_term}' dans #{recipe.name} — à ajouter manuellement"
    msg += " (#{note})" if note
    WARNINGS << msg
    puts msg
    return false
  end

  type, id = result
  rc = recipe.recipe_components.build(
    component_type: type,
    component_id:   id,
    quantity_kg:    qty_kg.to_f.round(6),
    quantity_unit:  "kg"
  )

  if rc.save
    note_str = note ? " [#{note}]" : ""
    puts "    + #{search_term} (#{type} #{id}) #{qty_kg} kg#{note_str}"
    true
  else
    msg = "  ⚠️  ERREUR save #{search_term} dans #{recipe.name}: #{rc.errors.full_messages.join(', ')}"
    WARNINGS << msg
    puts msg
    false
  end
end

def create_sauce(user, name)
  r = user.recipes.create!(
    name:                  name,
    sellable_as_component: true,
    cooking_loss_percentage: 0
  )
  puts "\n✅ SR créée : #{r.name} (ID #{r.id})"
  CREATED << "SR #{r.id} — #{r.name}"
  r
end

def create_feuillete(user, name, pate_kg, sauce_id, sauce_name)
  r = user.recipes.create!(
    name:                  name,
    sellable_as_component: false,
    cooking_loss_percentage: 0
  )
  puts "\n✅ R  créée : #{r.name} (ID #{r.id})"

  # Pâte feuilletée
  rc_pate = r.recipe_components.build(
    component_type: "Recipe",
    component_id:   PATE_FEUILLETEE_ID,
    quantity_kg:    pate_kg,
    quantity_unit:  "kg"
  )
  if rc_pate.save
    puts "    + Pâte Feuilletée (Recipe #{PATE_FEUILLETEE_ID}) #{pate_kg} kg"
  else
    WARNINGS << "  ⚠️  ERREUR pâte dans #{r.name}: #{rc_pate.errors.full_messages.join(', ')}"
  end

  # Sauce
  rc_sauce = r.recipe_components.build(
    component_type: "Recipe",
    component_id:   sauce_id,
    quantity_kg:    0.0,  # placeholder — set below
    quantity_unit:  "kg"
  )
  # On doit passer par quantity_kg directement car l'unité est kg
  rc_sauce.quantity_kg = (name.include?("4 portions") ? 0.5 : 0.8).to_f
  rc_sauce.quantity_kg = 0.5 if name.include?("4 portions")
  rc_sauce.quantity_kg = 0.8 if name.include?("6 portions")
  if rc_sauce.save
    puts "    + #{sauce_name} (Recipe #{sauce_id}) #{rc_sauce.quantity_kg} kg"
  else
    WARNINGS << "  ⚠️  ERREUR sauce dans #{r.name}: #{rc_sauce.errors.full_messages.join(', ')}"
  end

  Recalculations::Dispatcher.recipe_changed(r)
  CREATED << "R  #{r.id} — #{r.name}"
  r
end

# ─────────────────────────────────────────────
# DONNÉES DES 7 SAUCES
# ─────────────────────────────────────────────

SAUCES_DATA = [
  {
    name: "Sauce feuilleté fruits de mer",
    ingredients: [
      { s: "Moules",           qty: 9.000 },
      { s: "Crevettes",        qty: 6.000 },
      { s: "Ecrevisses",       qty: 4.000 },
      { s: "Pétoncles",        qty: 0.300,  note: "3 pièces ~100g/pc estimé — À VÉRIFIER" },
      { s: "Champignons",      qty: 0.400,  note: "1 boîte ~400g estimé — À VÉRIFIER" },
      { s: "Vin blanc",        qty: 1.000 },
      { s: "Echalote",         qty: 0.500 },
      { s: "Saumon",           qty: 7.500 },
      { s: "Merlan",           qty: 7.500 },
      { s: "Quenelles saumon", qty: 2.000 },
      { s: "Lait",             qty: 20.000 },
      { s: "Crème",            qty: 13.000 },
      { s: "Fumet crustacé",   qty: 0.400 },
      { s: "Fumet homard",     qty: 0.400 },
      { s: "Roux",             qty: 9.000 },
      { s: "Sel",              qty: 0.330 },
      { s: "Poivre",           qty: 0.020 },
    ]
  },
  {
    name: "Sauce feuilleté bleu",
    ingredients: [
      { s: "Lait",    qty: 3.000 },
      { s: "Crème",   qty: 2.000 },
      { s: "Bleu",    qty: 3.000 },
      { s: "Noix",    qty: 0.250 },
      { s: "Roux",    qty: 1.700 },
      { s: "Poivre",  qty: 0.010 },
    ]
  },
  {
    name: "Sauce feuilleté ris de veau",
    ingredients: [
      { s: "Ris de veau",   qty: 60.000 },
      { s: "Morilles",      qty: 11.500 },
      { s: "Eau",           qty: 15.000 },
      { s: "Beurre",        qty: 1.500 },
      { s: "Echalote",      qty: 2.000 },
      { s: "Porto",         qty: 3.000 },
      { s: "Sauce morille", qty: 0.600 },
      { s: "Sauce pizza",   qty: 1.500 },
      { s: "Lait",          qty: 40.000 },
      { s: "Crème",         qty: 36.000 },
      # Roux: quantité manquante — mail client envoyé
      { s: "Sel",           qty: 1.050,  note: "100g (cuisson) + 950g (sauce) = 1050g total" },
      { s: "Poivre",        qty: 0.040 },
    ]
  },
  {
    name: "Sauce feuilleté saumon",
    ingredients: [
      { s: "Saumon",          qty: 60.000 },
      { s: "Fumet",           qty: 15.000 },
      { s: "Lait",            qty: 30.000 },
      { s: "Crème",           qty: 30.000 },
      { s: "Vin blanc",       qty: 1.200 },
      { s: "Eau",             qty: 0.800 },
      { s: "Echalote",        qty: 1.000 },
      { s: "Fumet écrevisse", qty: 0.800 },
      { s: "Fumet homard",    qty: 0.800 },
      { s: "Fumet crustacé",  qty: 0.400 },
      { s: "Tomatina",        qty: 0.400,  note: "1 boîte ~400g estimé — À VÉRIFIER" },
      { s: "Roux",            qty: 22.000 },
      { s: "Sel",             qty: 0.720 },
      { s: "Poivre",          qty: 0.030 },
    ]
  },
  {
    name: "Béchamel feuilleté jambon",
    ingredients: [
      { s: "Lait",     qty: 12.000 },
      { s: "Crème",    qty: 8.000 },
      { s: "Roux",     qty: 4.500 },
      { s: "Picardan", qty: 1.000 },
      { s: "Sel",      qty: 0.200 },
      { s: "Poivre",   qty: 0.010 },
      { s: "Muscade",  qty: 0.005 },
    ]
  },
  {
    name: "Sauce feuilleté écrevisses",
    ingredients: [
      { s: "Ecrevisses",        qty: 8.000 },
      { s: "Julienne",          qty: 4.000 },
      { s: "Eau",               qty: 2.500 },
      { s: "Vin blanc",         qty: 0.500 },
      { s: "Crème",             qty: 6.000 },
      { s: "Lait",              qty: 2.000 },
      { s: "Sauce écrevisse",   qty: 0.400 },
      { s: "Sauce langoustine", qty: 0.100 },
      { s: "Sauce pizza",       qty: 0.500 },
      { s: "Roux",              qty: 2.500 },
    ]
  },
  {
    name: "Sauce feuilleté poulet",
    ingredients: [
      { s: "Blanc poulet",      qty: 62.500 },
      { s: "Morilles",          qty: 11.000 },
      { s: "Beurre",            qty: 1.500 },
      { s: "Echalote",          qty: 1.500 },
      { s: "Pulpe échalote",    qty: 0.500 },
      { s: "Lait",              qty: 48.000 },
      { s: "Crème",             qty: 36.000 },
      { s: "Sauce girolles",    qty: 2.000,  note: "2 pots — poids par pot à vérifier, 1kg/pot estimé" },
      { s: "Sauce champignons", qty: 1.000,  note: "1 pot — poids à vérifier, 1kg estimé" },
      { s: "Vin blanc",         qty: 2.000 },
      { s: "Eau",               qty: 4.000 },
      { s: "Sauce pizza",       qty: 2.500 },
      { s: "Roux",              qty: 24.500 },
      { s: "Sel",               qty: 0.950 },
      { s: "Poivre",            qty: 0.050 },
    ]
  }
].freeze

# ─────────────────────────────────────────────
# EXECUTION
# ─────────────────────────────────────────────

ActiveRecord::Base.transaction do

  # 1) Créer les 7 sous-recettes de sauce + leurs composants
  sauce_recipes = {}

  SAUCES_DATA.each do |sauce|
    sr = create_sauce(user, sauce[:name])
    sauce[:ingredients].each do |ing|
      add_ingredient(sr, user, ing[:s], ing[:qty], note: ing[:note])
    end
    Recalculations::Dispatcher.recipe_changed(sr)
    sauce_recipes[sauce[:name]] = sr
  end

  # 2) Créer les 14 recettes feuilletés (7 × 4p + 7 × 6p)
  puts "\n" + "=" * 60
  puts "CRÉATION DES 14 RECETTES FEUILLETÉS"
  puts "=" * 60

  [
    ["fruits de mer", "Sauce feuilleté fruits de mer"],
    ["bleu",          "Sauce feuilleté bleu"],
    ["ris de veau",   "Sauce feuilleté ris de veau"],
    ["saumon",        "Sauce feuilleté saumon"],
    ["jambon",        "Béchamel feuilleté jambon"],
    ["écrevisses",    "Sauce feuilleté écrevisses"],
    ["poulet",        "Sauce feuilleté poulet"],
  ].each do |label, sauce_name|
    sr = sauce_recipes[sauce_name]
    next puts "⚠️  Sauce '#{sauce_name}' introuvable, skip" unless sr

    create_feuillete(user, "Feuilleté #{label} 4 portions", 0.420, sr.id, sauce_name)
    create_feuillete(user, "Feuilleté #{label} 6 portions", 0.550, sr.id, sauce_name)
  end

  # ─── Récap final ───
  puts "\n" + "=" * 60
  puts "RÉCAP"
  puts "=" * 60
  puts "\n#{CREATED.size} recette(s) créée(s) :"
  CREATED.each { |c| puts "  #{c}" }

  if WARNINGS.any?
    puts "\n#{WARNINGS.size} AVERTISSEMENT(S) — À VÉRIFIER MANUELLEMENT :"
    WARNINGS.each { |w| puts w }
  else
    puts "\nAucun avertissement."
  end

end
