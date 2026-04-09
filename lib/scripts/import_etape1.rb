# encoding: utf-8
# ============================================================
# ÉTAPE 1 — Recettes/sous-recettes sans dépendances
# Produits bruts uniquement, aucune sous-recette en composant
# ============================================================
# Règle unités :
#   unit: "kg"    → stocké tel quel
#   unit: "g"     → converti en kg (/1000)
#   unit: "l"     → stocké tel quel (produit base_unit "l")
#   unit: "piece" → stocké tel quel (produit base_unit "piece")
# ============================================================

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")
$skip_adds = false

# ── Helpers ──────────────────────────────────────────────────

def p!(user, *patterns, base_unit: "kg")
  patterns.each do |pat|
    prod = user.products.where("name ILIKE ?", "%#{pat}%").first
    return prod if prod
  end
  name = patterns.first
  puts "  ✨ Produit créé (0€) : #{name} [#{base_unit}]"
  user.products.create!(name: name, base_unit: base_unit)
end

def upsert!(user, name, sub: false)
  r = user.recipes.where("name ILIKE ?", name).first
  if r
    $skip_adds = true
    puts "  SKIP (déjà en base) : #{name}"
    return r
  end
  $skip_adds = false
  r = user.recipes.new(
    name:                   name,
    sellable_as_component:  sub,
    cooking_loss_percentage: 0
  )
  r.save!
  puts "  ✓ #{sub ? '[SR]' : '[R] '} #{name}"
  r
end

def add!(recipe, comp, qty, unit: "kg")
  return if $skip_adds
  stored = unit == "g" ? qty / 1000.0 : qty.to_f
  existing = recipe.recipe_components.find_by(component: comp)
  if existing
    existing.update!(quantity_kg: existing.quantity_kg + stored)
  else
    recipe.recipe_components.create!(component: comp, quantity_kg: stored)
  end
rescue => e
  puts "    ❌ #{comp.name} : #{e.message}"
end

# ── Produits courants (probablement déjà en base) ────────────

beurre         = p!(user, "beurre motte", "beurre")
beurre_trace   = p!(user, "beurre trace", "beurre tracé")
farine         = p!(user, "farine")
sel            = p!(user, "sel")
sucre          = p!(user, "sucre")
lait           = p!(user, "lait",          base_unit: "l")
creme_liquide  = p!(user, "creme liquide", "crème liquide", base_unit: "l")
creme_epaisse  = p!(user, "creme epaisse", "crème épaisse", "crème fraiche")
eau            = p!(user, "eau",            base_unit: "l")
ail            = p!(user, "ail")
levure         = p!(user, "levure")
poivre         = p!(user, "poivre")
muscade        = p!(user, "muscade")
echalote       = p!(user, "echalote", "échalote")
persil         = p!(user, "persil")
thym           = p!(user, "thym")

# ── Produits spécifiques (créés à 0€ si absents) ─────────────

sucre_glace    = p!(user, "sucre glace")
fecule         = p!(user, "fecule", "fécule")
poudre_amande  = p!(user, "poudre amande", "amande grise", "amandes poudre")
vanille        = p!(user, "vanille")
cognac         = p!(user, "cognac",         base_unit: "l")
oeuf_liquide   = p!(user, "oeuf liquide",  "oeufs liquide")
oeufs_entiers  = p!(user, "oeuf",          "oeufs",         base_unit: "piece")
jaune_oeuf     = p!(user, "jaune oeuf",    "jaune d'oeuf",  "jaunes oeufs", "jaune")
amidon         = p!(user, "amidon",        "poudre flan",   "poudre à flan")
noix           = p!(user, "noix")
anchois        = p!(user, "anchois")
ricard         = p!(user, "ricard",        "pastis",        base_unit: "l")
moutarde       = p!(user, "moutarde")
vinaigre       = p!(user, "vinaigre")
huile_tournesol = p!(user, "huile tournesol", "tournesol",  base_unit: "l")
pomme_de_terre = p!(user, "pomme de terre", "pommes de terre")
aligot_tomme   = p!(user, "aligot",        "tomme fraiche", "tomme")
ameliorant     = p!(user, "ameliorant",    "améliorant")
poudre_puree   = p!(user, "poudre puree", "purée poudre", "flocon puree", "mousline")

puts "\n#{'='*60}"
puts "ÉTAPE 1 — Import"
puts "="*60

# ─────────────────────────────────────────────────────────────
# SOUS-RECETTES (sellable_as_component: true)
# ─────────────────────────────────────────────────────────────

# 1. Pâte sucrée
puts "\n── Pâte sucrée ──"
r = upsert!(user, "Pâte sucrée", sub: true)
add!(r, beurre,        15,    unit: "kg")
add!(r, sucre_glace,   14.5,  unit: "kg")
add!(r, fecule,        8,     unit: "kg")
add!(r, poudre_amande, 4.5,   unit: "kg")
add!(r, sel,           200,   unit: "g")
add!(r, vanille,       100,   unit: "g")
add!(r, farine,        30,    unit: "kg")
add!(r, oeuf_liquide,  9,     unit: "kg")

# 2. Pâte pâté croûte
puts "\n── Pâte pâté croûte ──"
r = upsert!(user, "Pâte pâté croûte", sub: true)
add!(r, farine,       42,    unit: "kg")
add!(r, sel,          840,   unit: "g")
add!(r, sucre,        840,   unit: "g")
add!(r, beurre,       3.5,   unit: "kg")
add!(r, beurre_trace, 14,    unit: "kg")
add!(r, oeuf_liquide, 7,     unit: "l")   # 7 L d'œufs liquides
add!(r, cognac,       7,     unit: "l")   # 7 L cognac

# 3. Purée
puts "\n── Purée ──"
r = upsert!(user, "Purée", sub: true)
add!(r, eau,          1.5,  unit: "l")
add!(r, creme_epaisse, 500, unit: "g")
add!(r, beurre,       150,  unit: "g")
add!(r, poudre_puree, 400,  unit: "g")

# 4. Tant pour tant (T.P.T.)
puts "\n── Tant pour tant (T.P.T.) ──"
r = upsert!(user, "Tant pour tant (T.P.T.)", sub: true)
add!(r, sucre_glace,   6,   unit: "kg")
add!(r, poudre_amande, 4,   unit: "kg")
add!(r, farine,        2,   unit: "kg")
add!(r, levure,        100, unit: "g")

# 5. Crème pâtissière
puts "\n── Crème pâtissière ──"
r = upsert!(user, "Crème pâtissière", sub: true)
add!(r, lait,       1,   unit: "l")
add!(r, sucre,      250, unit: "g")
add!(r, jaune_oeuf, 200, unit: "g")
add!(r, farine,     50,  unit: "g")
add!(r, amidon,     50,  unit: "g")

# 6. Crème anglaise
# ⚠️ Vanille : pas de quantité sur la photo → à ajouter manuellement
puts "\n── Crème anglaise ──"
r = upsert!(user, "Crème anglaise", sub: true)
add!(r, lait,          1,  unit: "l")
add!(r, oeufs_entiers, 8,  unit: "piece")
add!(r, sucre,         250, unit: "g")

# 7. Beurre escargots
puts "\n── Beurre escargots ──"
r = upsert!(user, "Beurre escargots", sub: true)
add!(r, persil,   750, unit: "g")
add!(r, echalote, 120, unit: "g")
add!(r, ail,      120, unit: "g")
add!(r, sel,      150, unit: "g")
add!(r, poivre,   10,  unit: "g")
add!(r, thym,     6,   unit: "g")
add!(r, muscade,  6,   unit: "g")
add!(r, noix,     200, unit: "g")
add!(r, anchois,  150, unit: "g")
add!(r, ricard,   100, unit: "g")   # indiqué en g sur la fiche
add!(r, beurre,   6,   unit: "kg")  # beurre ramolli

# 8. Mayonnaise
puts "\n── Mayonnaise ──"
r = upsert!(user, "Mayonnaise", sub: true)
add!(r, jaune_oeuf,      2,   unit: "kg")
add!(r, moutarde,        1,   unit: "kg")
add!(r, sel,             100, unit: "g")
add!(r, poivre,          20,  unit: "g")
add!(r, vinaigre,        300, unit: "g")   # indiqué en g sur la fiche
add!(r, huile_tournesol, 13,  unit: "l")

# 9. Gratin dauphinois (sub: true → utilisé dans Pâté pommes de terre)
puts "\n── Gratin dauphinois ──"
r = upsert!(user, "Gratin dauphinois", sub: true)
add!(r, pomme_de_terre, 44,  unit: "kg")
add!(r, creme_liquide,  12,  unit: "l")
add!(r, lait,           12,  unit: "l")
add!(r, beurre,         500, unit: "g")
add!(r, sel,            430, unit: "g")
add!(r, poivre,         30,  unit: "g")
add!(r, muscade,        10,  unit: "g")
add!(r, ail,            500, unit: "g")

# ─────────────────────────────────────────────────────────────
# RECETTES (sellable_as_component: false)
# ─────────────────────────────────────────────────────────────

# 10. Aligot
puts "\n── Aligot ──"
r = upsert!(user, "Aligot", sub: false)
add!(r, aligot_tomme, 2,   unit: "kg")
add!(r, eau,          700, unit: "g")   # indiqué en g sur la fiche
add!(r, creme_epaisse,300, unit: "g")   # indiqué en g sur la fiche
add!(r, ail,          20,  unit: "g")
add!(r, poudre_puree, 80,  unit: "g")

# 11. Brioche nature
puts "\n── Brioche nature ──"
r = upsert!(user, "Brioche nature", sub: false)
add!(r, farine,        5.2, unit: "kg")
add!(r, sel,           100, unit: "g")
add!(r, sucre,         700, unit: "g")
add!(r, levure,        250, unit: "g")
add!(r, oeufs_entiers, 50,  unit: "piece")
add!(r, beurre_trace,  1,   unit: "kg")
add!(r, beurre,        1.5, unit: "kg")

# 12. Brioche aux grattons
puts "\n── Brioche aux grattons ──"
r = upsert!(user, "Brioche aux grattons", sub: false)
add!(r, farine,        5.2, unit: "kg")
add!(r, sel,           100, unit: "g")
add!(r, sucre,         250, unit: "g")
add!(r, levure,        700, unit: "g")
add!(r, oeufs_entiers, 50,  unit: "piece")
add!(r, beurre_trace,  1,   unit: "kg")
add!(r, beurre,        1.5, unit: "kg")   # "beurre fin"
add!(r, ameliorant,    200, unit: "g")

# ─────────────────────────────────────────────────────────────
# PÂTE BRISÉE — Placeholder (à compléter manuellement)
# ─────────────────────────────────────────────────────────────

puts "\n── Pâte brisée (placeholder) ──"
r = upsert!(user, "Pâte brisée", sub: true)
add!(r, eau, 0.001, unit: "l")

puts "\n#{'='*60}"
puts "✅ Étape 1 terminée — 13 recettes/sous-recettes"
puts ""
puts "Points à vérifier manuellement :"
puts "  · Crème anglaise : Vanille (pas de quantité sur la fiche)"
puts "  · Pâte brisée    : ingrédients à compléter"
puts "  · Produits créés à 0€ ci-dessus → à pricer dans Produits"
puts "="*60
