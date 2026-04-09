# encoding: utf-8
# ============================================================
# ÉTAPE 2 — Sous-recettes avec dépendances
# Groupe A : dépendent de Roux / Sauce pizza (déjà en base)
# Groupe B : dépendent de Sauce champagne (créée en groupe A)
# Recettes finales
# ============================================================
# Note : les "Sauce X" en petites quantités (250g, 500g, 1 boîte)
# sont des concentrés commerciaux achetés → créés comme produits.
# Seules "Sauce pizza" et "Sauce champagne" sont nos sous-recettes.
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

def sr!(user, *patterns)
  patterns.each do |pat|
    r = user.recipes.where("name ILIKE ?", "%#{pat}%").first
    return r if r
  end
  raise "❌ Sous-recette introuvable : #{patterns.join(' / ')}"
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
    name:                    name,
    sellable_as_component:   sub,
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

# ── Sous-recettes existantes en base ─────────────────────────

roux            = sr!(user, "roux")
sauce_pizza     = sr!(user, "sauce pizza")
pate_feuilletee = sr!(user, "pâte feuilletée", "pate feuilletee")
gratin          = sr!(user, "gratin dauphinois")

# ── Produits courants ─────────────────────────────────────────

beurre         = p!(user, "beurre motte", "beurre")
sel            = p!(user, "sel")
poivre         = p!(user, "poivre")
sucre          = p!(user, "sucre")
creme          = p!(user, "crème", "creme")
lait           = p!(user, "lait",        base_unit: "l")
eau            = p!(user, "eau",         base_unit: "l")
ail            = p!(user, "ail")
echalote       = p!(user, "echalote", "échalote")
persil         = p!(user, "persil")
thym           = p!(user, "thym")
cognac         = p!(user, "cognac",      base_unit: "l")
vinaigre       = p!(user, "vinaigre")
huile_olive    = p!(user, "huile olive", "huile d'olive", base_unit: "l")
oignons        = p!(user, "oignons", "oignon")
oignons_pref   = p!(user, "oignons émincés préfrits", "oignons prefrits", "oignon prefrit", "prefrit")

# ── Vins, alcools, fonds ──────────────────────────────────────

fumet          = p!(user, "fumet",       base_unit: "l")
vin_blanc      = p!(user, "vin blanc",   base_unit: "l")
vin_rouge      = p!(user, "vin rouge",   base_unit: "l")
champagne      = p!(user, "champagne",   base_unit: "l")
vermouth       = p!(user, "vermouth",    base_unit: "l")
porto          = p!(user, "porto",       base_unit: "l")
cremant        = p!(user, "cremant", "crémant", base_unit: "l")
grand_marnier  = p!(user, "grand marnier", base_unit: "l")
bouillon       = p!(user, "bouillon",    base_unit: "l")
fond_volaille  = p!(user, "fond volaille", "fond de volaille")
fond_de_veau   = p!(user, "fond de veau", "fond veau")
fond_de_civet  = p!(user, "fond civet",   "fond de civet")
glace_canard   = p!(user, "glace canard")
glace_volaille = p!(user, "glace volaille")

# ── Produits spécialisés ──────────────────────────────────────

jus_orange       = p!(user, "pulco orange", "jus orange")
pulco_citron     = p!(user, "pulco citron", "jus citron")
miel             = p!(user, "miel")
foie_gras        = p!(user, "foie gras")
brisure_truffe   = p!(user, "brisure truffe")
arome_truffe     = p!(user, "arome truffe", "arôme truffe")
sauce_figue      = p!(user, "sauce figue",  "figue")
ris_de_veau      = p!(user, "ris de veau")
morilles         = p!(user, "morille", "morilles")
noix             = p!(user, "noix")
bleu             = p!(user, "bleu", "fromage bleu")
oseille          = p!(user, "oseille")
lardons          = p!(user, "lardon", "lardons")
poulet           = p!(user, "blanc poulet", "poulet blanc", "poulet")
courgettes       = p!(user, "courgette", "courgettes")
tomates          = p!(user, "tomate", "tomates")
poivrons         = p!(user, "poivron", "poivrons")
poivrons_cuist   = p!(user, "poivron cuisiné", "poivrons cuisinés")
sacs_ratatouille = p!(user, "sac ratatouille", "ratatouille sac")
concentre_tomate = p!(user, "concentre tomate", "concentré tomate")
poudre_tomate    = p!(user, "poudre tomate",    "tomate poudre")
tomate_proven    = p!(user, "tomate provencale", "provençale tomate")
origan           = p!(user, "origan")
piment           = p!(user, "piment")
fumet_stj        = p!(user, "fumet st jacques")
jus_langoustine  = p!(user, "jus langoustine", "langoustine jus")

# ── Concentrés commerciaux (sauces achetées) ─────────────────

ssc_safran    = p!(user, "sauce safran")
ssc_stj       = p!(user, "sauce st jacques")
ssc_champign  = p!(user, "sauce champignon")
ssc_girolles  = p!(user, "sauce girolles")
ssc_morille   = p!(user, "sauce morille")
ssc_ecrevisse = p!(user, "sauce ecrevisse")
ssc_homard    = p!(user, "sauce homard")
ssc_crustace  = p!(user, "sauce crustace", "sauce crustacé")
ssc_armoric   = p!(user, "sauce armoricaine", "armoricaine")
ssc_truffe    = p!(user, "sauce truffe")

puts "\n#{'='*60}"
puts "ÉTAPE 2 — Import"
puts "="*60

# ─────────────────────────────────────────────────────────────
# GROUPE A — Dépendent de Roux / Sauce pizza
# ─────────────────────────────────────────────────────────────

puts "\n── Feuillette bleue ──"
r = upsert!(user, "Feuillette bleue", sub: true)
add!(r, lait,    3,   unit: "l")
add!(r, creme,   2,   unit: "l")
add!(r, bleu,    3,   unit: "kg")
add!(r, noix,    250, unit: "g")
add!(r, roux,    1.7, unit: "kg")
add!(r, poivre,  10,  unit: "g")

puts "\n── Sauce champagne ──"
r = upsert!(user, "Sauce champagne", sub: true)
add!(r, beurre,      500,  unit: "g")
add!(r, echalote,    10,   unit: "g")
add!(r, vermouth,    2,    unit: "l")
add!(r, vin_blanc,   2,    unit: "l")
add!(r, champagne,   0.75, unit: "l")   # 1 bouteille (réduction)
add!(r, fumet,       24,   unit: "l")
add!(r, creme,       24,   unit: "l")   # crème liquide
add!(r, creme,       2,    unit: "kg")  # crème épaisse (même produit)
add!(r, ssc_safran,  250,  unit: "g")
add!(r, ssc_stj,     500,  unit: "g")
add!(r, sel,         440,  unit: "g")
add!(r, poivre,      20,   unit: "g")
add!(r, roux,        3.5,  unit: "kg")
add!(r, champagne,   1.5,  unit: "l")   # 2 bouteilles (final)

puts "\n── Sauce Américaine ──"
r = upsert!(user, "Sauce Américaine", sub: true)
add!(r, beurre,       1,   unit: "kg")
add!(r, echalote,     1,   unit: "kg")
add!(r, cognac,       2,   unit: "l")
add!(r, vin_blanc,    2,   unit: "l")
add!(r, fumet,        22,  unit: "l")
add!(r, eau,          18,  unit: "l")
add!(r, jus_langoustine, 1, unit: "piece")  # 1 boîte
add!(r, ssc_homard,   2,   unit: "piece")   # 2 boîtes
add!(r, ssc_crustace, 1,   unit: "piece")   # 1 boîte
add!(r, ssc_armoric,  2,   unit: "piece")   # 2 boîtes
add!(r, sauce_pizza,  2,   unit: "kg")
add!(r, creme,        5,   unit: "l")
add!(r, grand_marnier, 1,  unit: "l")
add!(r, roux,         2.5, unit: "kg")
add!(r, sel,          250, unit: "g")
add!(r, poivre,       20,  unit: "g")
add!(r, piment,       6,   unit: "g")

puts "\n── Sauce porto ──"
r = upsert!(user, "Sauce porto", sub: true)
add!(r, bouillon,     5,   unit: "l")
add!(r, eau,          5,   unit: "l")
add!(r, ssc_champign, 500, unit: "g")
add!(r, creme,        1.5, unit: "l")
add!(r, sauce_pizza,  1,   unit: "kg")
add!(r, porto,        1,   unit: "l")
add!(r, roux,         500, unit: "g")
add!(r, poivre,       10,  unit: "g")

puts "\n── Sauce morilles ──"
r = upsert!(user, "Sauce morilles", sub: true)
add!(r, beurre,       400, unit: "g")
add!(r, oignons_pref, 1,   unit: "kg")
add!(r, sucre,        200, unit: "g")
add!(r, vin_blanc,    1,   unit: "l")
add!(r, eau,          10,  unit: "l")
add!(r, ssc_morille,  300, unit: "g")
add!(r, ssc_girolles, 500, unit: "g")
add!(r, fond_volaille, 200, unit: "g")
add!(r, creme,        8,   unit: "l")
add!(r, sel,          160, unit: "g")
add!(r, poivre,       20,  unit: "g")
add!(r, roux,         800, unit: "g")

puts "\n── Sauce truffe ──"
r = upsert!(user, "Sauce truffe", sub: true)
add!(r, eau,          10,   unit: "l")
add!(r, glace_volaille, 150, unit: "g")
add!(r, glace_canard, 250, unit: "g")
add!(r, ssc_champign, 400, unit: "g")
add!(r, creme,        4,   unit: "l")
add!(r, lait,         2,   unit: "l")
add!(r, ssc_truffe,   100, unit: "g")
add!(r, arome_truffe, 40,  unit: "g")
add!(r, brisure_truffe, 100, unit: "g")
add!(r, sel,          180, unit: "g")
add!(r, poivre,       20,  unit: "g")
add!(r, oignons,      1,   unit: "kg")
add!(r, beurre,       250, unit: "g")
add!(r, vin_blanc,    1,   unit: "l")
add!(r, cremant,      0.75, unit: "l")  # 1 bouteille
add!(r, roux,         1.25, unit: "kg")

puts "\n── Sauce sole ──"
r = upsert!(user, "Sauce sole", sub: true)
add!(r, fumet,        30,  unit: "l")
add!(r, eau,          10,  unit: "l")
add!(r, ssc_morille,  800, unit: "g")
add!(r, creme,        39,  unit: "l")
add!(r, lait,         8,   unit: "l")
add!(r, creme,        2,   unit: "kg")  # crème épaisse
add!(r, sel,          700, unit: "g")
add!(r, poivre,       30,  unit: "g")
add!(r, roux,         5.5, unit: "kg")
add!(r, fumet_stj,    1,   unit: "piece")  # 1 boîte

puts "\n── Sauce périgueux ──"
r = upsert!(user, "Sauce périgueux", sub: true)
add!(r, beurre,        500, unit: "g")
add!(r, echalote,      500, unit: "g")
add!(r, cognac,        1.3, unit: "l")
add!(r, porto,         1.3, unit: "l")
add!(r, vin_blanc,     2,   unit: "l")
add!(r, fond_de_veau,  12,  unit: "l")
add!(r, eau,           8,   unit: "l")
add!(r, foie_gras,     1,   unit: "kg")
add!(r, creme,         4,   unit: "l")
add!(r, brisure_truffe, 50, unit: "g")
add!(r, sel,           160, unit: "g")
add!(r, poivre,        20,  unit: "g")
add!(r, sauce_figue,   20,  unit: "g")
add!(r, roux,          1.4, unit: "kg")

puts "\n── Sauce à l'orange ──"
r = upsert!(user, "Sauce à l'orange", sub: true)
add!(r, vinaigre,     5,   unit: "l")
add!(r, sucre,        3,   unit: "kg")
add!(r, jus_orange,   6,   unit: "l")
add!(r, eau,          20,  unit: "l")
add!(r, glace_canard, 1,   unit: "piece")  # 1 boîte
add!(r, creme,        4,   unit: "l")
add!(r, sel,          180, unit: "g")
add!(r, poivre,       20,  unit: "g")
add!(r, grand_marnier, 1,  unit: "l")
add!(r, roux,         1.2, unit: "kg")
add!(r, miel,         400, unit: "g")

puts "\n── Sauce lapin ──"
r = upsert!(user, "Sauce lapin", sub: true)
add!(r, vin_rouge,    2,   unit: "l")
add!(r, eau,          5,   unit: "l")
add!(r, ail,          100, unit: "g")
add!(r, sel,          80,  unit: "g")
add!(r, poivre,       20,  unit: "g")
add!(r, thym,         3,   unit: "g")   # 1 pincée
add!(r, fond_volaille, 300, unit: "g")
add!(r, oignons,      600, unit: "g")
add!(r, sauce_pizza,  1,   unit: "kg")
add!(r, fond_de_civet, 250, unit: "g")

puts "\n── Sauce quenelles de brochet ──"
r = upsert!(user, "Sauce quenelles de brochet", sub: true)
add!(r, fumet,         2.2, unit: "l")
add!(r, eau,           20,  unit: "l")
add!(r, creme,         15,  unit: "l")
add!(r, creme,         1.5, unit: "kg")  # crème épaisse
add!(r, ssc_crustace,  1,   unit: "piece")
add!(r, ssc_homard,    1,   unit: "piece")
add!(r, ssc_ecrevisse, 600, unit: "g")
add!(r, jus_langoustine, 1, unit: "kg")
add!(r, concentre_tomate, 2.5, unit: "kg")
add!(r, sauce_pizza,   2.3, unit: "kg")
add!(r, roux,          350, unit: "g")
add!(r, sel,           30,  unit: "g")
add!(r, poivre,        6,   unit: "g")
add!(r, piment,        3,   unit: "g")

puts "\n── Sauce Provençale ──"
r = upsert!(user, "Sauce Provençale", sub: true)
add!(r, huile_olive,    800, unit: "g")
add!(r, oignons,        3,   unit: "kg")
add!(r, poivrons_cuist, 2,   unit: "piece")  # 2 boîtes
add!(r, eau,            12,  unit: "l")
add!(r, poudre_tomate,  500, unit: "g")
add!(r, tomate_proven,  500, unit: "g")
add!(r, sauce_pizza,    3,   unit: "kg")
add!(r, sel,            160, unit: "g")
add!(r, poivre,         20,  unit: "g")
add!(r, sucre,          500, unit: "g")
add!(r, origan,         110, unit: "g")

puts "\n── Sauce ris de veau barquette ──"
r = upsert!(user, "Sauce ris de veau barquette", sub: true)
add!(r, beurre,      250, unit: "g")
add!(r, echalote,    250, unit: "g")
add!(r, morilles,    1,   unit: "piece")  # 1 sac
add!(r, ris_de_veau, 10,  unit: "kg")
add!(r, sauce_pizza, 500, unit: "g")
add!(r, creme,       500, unit: "g")
add!(r, lait,        7,   unit: "l")
add!(r, creme,       2,   unit: "l")     # crème épaisse
add!(r, sel,         500, unit: "g")
add!(r, poivre,      130, unit: "g")
add!(r, roux,        10,  unit: "g")

puts "\n── Sauce St Jacques ──"
r = upsert!(user, "Sauce St Jacques", sub: true)
add!(r, beurre,    500, unit: "g")
add!(r, echalote,  1,   unit: "kg")
add!(r, vin_blanc, 2,   unit: "l")
add!(r, vermouth,  2,   unit: "l")
add!(r, fumet,     20,  unit: "l")
add!(r, eau,       10,  unit: "l")
add!(r, creme,     24,  unit: "l")
add!(r, creme,     1,   unit: "l")     # crème épaisse
add!(r, ssc_safran, 200, unit: "g")
add!(r, ssc_stj,   1.5, unit: "kg")
add!(r, sel,       52,  unit: "g")
add!(r, poivre,    20,  unit: "g")
add!(r, roux,      3.2, unit: "kg")

puts "\n── Sauce agrumes ──"
r = upsert!(user, "Sauce agrumes", sub: true)
add!(r, beurre,     500, unit: "g")
add!(r, echalote,   500, unit: "g")
add!(r, vin_blanc,  2,   unit: "l")
add!(r, vermouth,   2,   unit: "l")
add!(r, fumet,      22,  unit: "l")
add!(r, creme,      26,  unit: "l")
add!(r, lait,       8,   unit: "l")
add!(r, ssc_safran, 1,   unit: "piece")  # 1 boîte
add!(r, ssc_stj,    400, unit: "g")
add!(r, jus_orange, 500, unit: "g")
add!(r, pulco_citron, 500, unit: "g")
add!(r, grand_marnier, 500, unit: "g")
add!(r, sel,        20,  unit: "g")
add!(r, roux,       3.2, unit: "kg")

# ─────────────────────────────────────────────────────────────
# GROUPE B — Dépendent de Sauce champagne
# ─────────────────────────────────────────────────────────────

sauce_champagne = sr!(user, "sauce champagne")

puts "\n── Sauce safran ──"
r = upsert!(user, "Sauce safran", sub: true)
add!(r, ssc_safran,      700, unit: "g")
add!(r, eau,             10,  unit: "l")
add!(r, sauce_champagne, 7.5, unit: "kg")
add!(r, roux,            600, unit: "g")
add!(r, sel,             100, unit: "g")
add!(r, poivre,          10,  unit: "g")
add!(r, creme,           7.5, unit: "l")

puts "\n── Sauce oseille ──"
r = upsert!(user, "Sauce oseille", sub: true)
add!(r, sauce_champagne, 2.5, unit: "kg")
add!(r, oseille,         400, unit: "g")

# ─────────────────────────────────────────────────────────────
# RECETTES FINALES
# ─────────────────────────────────────────────────────────────

sauce_provencale = sr!(user, "sauce provençale", "sauce provencale")

puts "\n── Ratatouille ──"
r = upsert!(user, "Ratatouille", sub: false)
add!(r, courgettes,      35,  unit: "kg")
add!(r, oignons_pref,    6,   unit: "kg")
add!(r, ail,             1.5, unit: "kg")
add!(r, tomates,         33,  unit: "kg")
add!(r, sacs_ratatouille, 7.5, unit: "kg")
add!(r, poivrons,        1,   unit: "piece")  # 1 boîte
add!(r, sauce_pizza,     4.5, unit: "kg")

puts "\n── Blanc de poulet provençal ──"
r = upsert!(user, "Blanc de poulet provençal", sub: false)
add!(r, lardons,         50,  unit: "g")
add!(r, sauce_provencale, 900, unit: "g")
add!(r, poulet,          1,   unit: "kg")

puts "\n── Pâté pommes de terre ──"
r = upsert!(user, "Pâté pommes de terre", sub: false)
add!(r, pate_feuilletee, 350, unit: "g")
add!(r, gratin,          550, unit: "g")
add!(r, ail,             5,   unit: "g")
add!(r, echalote,        5,   unit: "g")
add!(r, persil,          5,   unit: "g")
add!(r, creme,           40,  unit: "g")

puts "\n#{'='*60}"
puts "✅ Étape 2 terminée"
puts "⚠️  Produits créés à 0€ → à pricer dans Produits"
puts "="*60
