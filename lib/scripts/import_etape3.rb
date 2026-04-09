# encoding: utf-8
# ============================================================
# ÉTAPE 3 — Sauces feuilletés, feuilletés, quiches, autres
# ============================================================
# Dépendances :
#   - Pâte feuilletée, Roux, Sauce pizza, Pâte brisée (existants)
#   - Sauce morilles (étape 2)
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
  $skip_ads = false
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

pate_feuilletee = sr!(user, "pâte feuilletée", "pate feuilletee")
roux            = sr!(user, "roux")
sauce_pizza     = sr!(user, "sauce pizza")
pate_brisee     = sr!(user, "pâte brisée", "pate brisee")

# ── Produits courants ─────────────────────────────────────────

beurre         = p!(user, "beurre motte", "beurre")
beurre_trace   = p!(user, "beurre trace", "beurre tracé")
sel            = p!(user, "sel")
poivre         = p!(user, "poivre")
sucre          = p!(user, "sucre")
creme          = p!(user, "crème", "creme")
lait           = p!(user, "lait",          base_unit: "l")
eau            = p!(user, "eau",            base_unit: "l")
ail            = p!(user, "ail")
echalote       = p!(user, "echalote", "échalote")
muscade        = p!(user, "muscade")
oignons        = p!(user, "oignons", "oignon")
persil         = p!(user, "persil")
piment         = p!(user, "piment")
egrene_boeuf   = p!(user, "egrene boeuf", "égrené boeuf", "boeuf haché")
vin_blanc      = p!(user, "vin blanc",      base_unit: "l")
porto          = p!(user, "porto",          base_unit: "l")
farine         = p!(user, "farine")
levure         = p!(user, "levure")
morilles       = p!(user, "morille", "morilles")
oeufs_entiers  = p!(user, "oeuf",          "oeufs",         base_unit: "piece")
oeuf_liquide   = p!(user, "oeuf liquide",  "oeufs liquide")
jaune_oeuf     = p!(user, "jaune oeuf",    "jaune d'oeuf",  "jaunes oeufs", "jaune")
ameliorant     = p!(user, "ameliorant",    "améliorant")
concentre_tomate = p!(user, "concentre tomate", "concentré tomate")
tomates        = p!(user, "tomate", "tomates")
huile_olive    = p!(user, "huile olive",   "huile d'olive", base_unit: "l")
lardons        = p!(user, "lardon", "lardons")
poulet         = p!(user, "blanc poulet",  "poulet blanc",  "poulet")
carottes       = p!(user, "carotte", "carottes")
fond_de_veau   = p!(user, "fond de veau",  "fond veau")
poudre_tomate  = p!(user, "poudre tomate", "tomate poudre")

# ── Produits spécifiques feuilletés ──────────────────────────

ecrevisses       = p!(user, "ecrevisse",      "écrevisse")
julienne         = p!(user, "julienne")
saumon           = p!(user, "saumon")
crevettes        = p!(user, "crevette",       "crevettes")
petoncles        = p!(user, "petoncle",       "pétoncle",   "saint-jacques coquille")
merlan           = p!(user, "merlan")
quenelles_saumon = p!(user, "quenelle saumon")
fumet_ecrevisse  = p!(user, "fumet ecrevisse", "fumet écrevisse")
fumet_homard     = p!(user, "fumet homard")
fumet_crustace   = p!(user, "fumet crustace",  "fumet crustacé")
tomatina         = p!(user, "tomatina")
champignons      = p!(user, "champignon",     "champignons")
ssc_ecrevisse    = p!(user, "sauce ecrevisse")
ssc_champign     = p!(user, "sauce champignon")
ssc_girolles     = p!(user, "sauce girolles")
ssc_morille      = p!(user, "sauce morille")
jus_langoustine  = p!(user, "jus langoustine", "langoustine jus")
pulpe_echalote   = p!(user, "pulpe echalote",  "échalote pulpe")
picardan         = p!(user, "picardan",         base_unit: "l")

# ── Produits spécifiques quiches ──────────────────────────────

jambon           = p!(user, "jambon")
gruyere          = p!(user, "gruyere", "gruyère")
asperges         = p!(user, "asperge", "asperges")
chevre           = p!(user, "chèvre",  "chevre")
epinard          = p!(user, "epinard", "épinard")
thon             = p!(user, "thon")
tartare_tomate   = p!(user, "tartare tomate")

# ── Produits spécifiques autres recettes ─────────────────────

chair_saucisse = p!(user, "chair saucisse", "saucisse chair")
chair_tomate   = p!(user, "chair tomate",   "tomate chair")
chou           = p!(user, "chou vert",      "chou frisé",   "chou")
jus_champignon = p!(user, "jus champignon")
sauce_gustosa  = p!(user, "sauce gustosa",  "gustosa")
chocolat       = p!(user, "chocolat")
margo          = p!(user, "margo")
sam_crois      = p!(user, "sam-crois",      "samcrois",      "sam crois")

puts "\n#{'='*60}"
puts "ÉTAPE 3 — Import"
puts "="*60

# ─────────────────────────────────────────────────────────────
# SAUCES FEUILLETÉS (sous-recettes)
# ─────────────────────────────────────────────────────────────

# 1. Sauce feuilleté écrevisses (photo IMG_8049)
puts "\n── Sauce feuilleté écrevisses ──"
r = upsert!(user, "Sauce feuilleté écrevisses", sub: true)
add!(r, ecrevisses,      8,   unit: "kg")
add!(r, julienne,        4,   unit: "kg")
add!(r, eau,             2.5, unit: "l")
add!(r, vin_blanc,       0.5, unit: "l")
add!(r, creme,           6,   unit: "l")
add!(r, lait,            2,   unit: "l")
add!(r, ssc_ecrevisse,   400, unit: "g")
add!(r, jus_langoustine, 100, unit: "g")
add!(r, sauce_pizza,     500, unit: "g")
add!(r, roux,            2.5, unit: "kg")

# 2. Sauce feuilleté fruits de mer (photo IMG_8050)
puts "\n── Sauce feuilleté fruits de mer ──"
r = upsert!(user, "Sauce feuilleté fruits de mer", sub: true)
add!(r, saumon,          9,   unit: "kg")
add!(r, crevettes,       6,   unit: "kg")
add!(r, petoncles,       4,   unit: "kg")
add!(r, ecrevisses,      3,   unit: "kg")
add!(r, champignons,     1,   unit: "piece")   # 1 boîte
add!(r, vin_blanc,       500, unit: "g")
add!(r, echalote,        1,   unit: "kg")
add!(r, merlan,          7.5, unit: "kg")
add!(r, quenelles_saumon, 2,  unit: "kg")
add!(r, creme,           20,  unit: "l")
add!(r, lait,            13,  unit: "l")
add!(r, fumet_ecrevisse, 400, unit: "g")
add!(r, fumet_crustace,  400, unit: "g")
add!(r, fumet_homard,    9,   unit: "kg")
add!(r, roux,            330, unit: "g")
add!(r, sel,             20,  unit: "g")
add!(r, poivre,          20,  unit: "g")

# 3. Sauce feuilleté ris de veau (photo IMG_8051)
# ⚠ Peut déjà exister en base — sera skippée si c'est le cas
puts "\n── Sauce feuilleté ris de veau ──"
r = upsert!(user, "Sauce feuilleté ris de veau", sub: true)
add!(r, morilles,    11.5, unit: "kg")
add!(r, eau,         15,   unit: "l")
add!(r, beurre,      1.5,  unit: "kg")
add!(r, echalote,    2,    unit: "kg")
add!(r, porto,       3,    unit: "l")
add!(r, ssc_morille, 600,  unit: "g")
add!(r, sauce_pizza, 1.5,  unit: "kg")
add!(r, lait,        40,   unit: "l")
add!(r, creme,       36,   unit: "l")
add!(r, roux,        950,  unit: "g")
add!(r, sel,         100,  unit: "g")
add!(r, poivre,      40,   unit: "g")

# 4. Sauce feuilleté poulet (photo IMG_8052)
puts "\n── Sauce feuilleté poulet ──"
r = upsert!(user, "Sauce feuilleté poulet", sub: true)
add!(r, poulet,       62.5, unit: "kg")
add!(r, morilles,     11,   unit: "kg")
add!(r, beurre,       1.5,  unit: "kg")
add!(r, echalote,     1.5,  unit: "kg")
add!(r, pulpe_echalote, 500, unit: "g")
add!(r, lait,         48,   unit: "l")
add!(r, creme,        36,   unit: "l")
add!(r, ssc_girolles, 2,    unit: "piece")    # 2 pots
add!(r, ssc_champign, 1,    unit: "piece")    # 1 pot
add!(r, vin_blanc,    2,    unit: "l")
add!(r, sauce_pizza,  2.5,  unit: "kg")
add!(r, roux,         24.5, unit: "kg")
add!(r, sel,          950,  unit: "g")
add!(r, poivre,       50,   unit: "g")

# 5. Sauce feuilleté saumon (photo IMG_8047)
puts "\n── Sauce feuilleté saumon ──"
r = upsert!(user, "Sauce feuilleté saumon", sub: true)
add!(r, saumon,         60,  unit: "kg")
add!(r, fumet_ecrevisse, 400, unit: "g")
add!(r, fumet_homard,   800, unit: "g")
add!(r, fumet_crustace, 400, unit: "g")
add!(r, lait,           30,  unit: "l")
add!(r, creme,          1.2, unit: "l")
add!(r, vin_blanc,      800, unit: "g")
add!(r, eau,            1,   unit: "kg")
add!(r, echalote,       800, unit: "g")
add!(r, tomatina,       1,   unit: "piece")   # 1 boîte
add!(r, roux,           22,  unit: "kg")
add!(r, sel,            720, unit: "g")
add!(r, poivre,         30,  unit: "g")

# 6. Béchamel feuilleté jambon (photo IMG_8048)
puts "\n── Béchamel feuilleté jambon ──"
r = upsert!(user, "Béchamel feuilleté jambon", sub: true)
add!(r, lait,     12,  unit: "l")
add!(r, creme,    8,   unit: "l")
add!(r, roux,     4.5, unit: "kg")
add!(r, picardan, 1,   unit: "l")
add!(r, sel,      200, unit: "g")
add!(r, poivre,   10,  unit: "g")
add!(r, muscade,  5,   unit: "g")

# 7. Sauce quiche (photo IMG_8053)
# ⚠ Peut déjà exister en base
puts "\n── Sauce quiche ──"
r = upsert!(user, "Sauce quiche", sub: true)
add!(r, lait,          10,  unit: "l")
add!(r, creme,         8,   unit: "l")
add!(r, creme,         2,   unit: "l")     # crème épaisse (même produit)
add!(r, roux,          1.3, unit: "kg")
add!(r, sel,           400, unit: "g")
add!(r, poivre,        10,  unit: "g")
add!(r, muscade,       5,   unit: "g")
add!(r, oeufs_entiers, 100, unit: "piece")
add!(r, oeuf_liquide,  4,   unit: "l")
add!(r, jaune_oeuf,    1,   unit: "kg")

# ─────────────────────────────────────────────────────────────
# FEUILLETÉS — Assemblage (pâte + sauce)
# Référence : pour 4 portions = 550g pâte + 800g sauce
# ─────────────────────────────────────────────────────────────

sauce_feuillet_ecrevisses  = sr!(user, "sauce feuilleté écrevisses", "sauce feuillet")
sauce_feuillet_ris_veau    = sr!(user, "sauce feuilleté ris de veau")
sauce_feuillet_poulet      = sr!(user, "sauce feuilleté poulet")
sauce_feuillet_saumon      = sr!(user, "sauce feuilleté saumon")
bechamel_jambon            = sr!(user, "béchamel feuilleté jambon", "bechamel feuillet")

puts "\n── Feuilleté écrevisses ──"
r = upsert!(user, "Feuilleté écrevisses", sub: false)
add!(r, pate_feuilletee,           550, unit: "g")
add!(r, sauce_feuillet_ecrevisses, 800, unit: "g")

puts "\n── Feuilleté ris de veau ──"
r = upsert!(user, "Feuilleté ris de veau", sub: false)
add!(r, pate_feuilletee,        550, unit: "g")
add!(r, sauce_feuillet_ris_veau, 800, unit: "g")

puts "\n── Feuilleté poulet ──"
r = upsert!(user, "Feuilleté poulet", sub: false)
add!(r, pate_feuilletee,       550, unit: "g")
add!(r, sauce_feuillet_poulet, 800, unit: "g")

puts "\n── Feuilleté saumon ──"
r = upsert!(user, "Feuilleté saumon", sub: false)
add!(r, pate_feuilletee,      550, unit: "g")
add!(r, sauce_feuillet_saumon, 800, unit: "g")

puts "\n── Feuilleté jambon ──"
r = upsert!(user, "Feuilleté jambon", sub: false)
add!(r, pate_feuilletee, 550, unit: "g")
add!(r, bechamel_jambon, 800, unit: "g")
add!(r, jambon,          100, unit: "g")

# ─────────────────────────────────────────────────────────────
# QUICHES (quantités par portion)
# ─────────────────────────────────────────────────────────────

sauce_quiche = sr!(user, "sauce quiche")

# Quiche lorraine (photo IMG_8054)
puts "\n── Quiche lorraine ──"
r = upsert!(user, "Quiche lorraine", sub: false)
add!(r, pate_brisee,  115, unit: "g")
add!(r, gruyere,      10,  unit: "g")
add!(r, jambon,       20,  unit: "g")
add!(r, lardons,      15,  unit: "g")
add!(r, sauce_quiche, 175, unit: "g")

# Quiche légumes (photo IMG_8054)
# Mélange légumes : julienne 5 kg + gruyère 1 kg + sel/poivre 30 g → 50 g par portion
puts "\n── Quiche légumes ──"
r = upsert!(user, "Quiche légumes", sub: false)
add!(r, pate_brisee,  115, unit: "g")  # ⚠ non indiqué, estimé
add!(r, julienne,     42,  unit: "g")  # 5 kg sur ~120 portions
add!(r, gruyere,      8,   unit: "g")  # 1 kg sur ~120 portions
add!(r, sauce_quiche, 180, unit: "g")

# Quiche thon tomate (photo IMG_8055)
# Mélange thon : 3 kg thon + 1.2 kg gruyère + 400 g poudre tomate → 30 g par portion
# Mélange tomate : 4 kg tomates + 350 g poudre tomate + 800 g S.Pizza + 1.6 kg tartare tomate → 60 g par portion
puts "\n── Quiche thon tomate ──"
r = upsert!(user, "Quiche thon tomate", sub: false)
add!(r, pate_brisee,   115, unit: "g")
add!(r, thon,          19,  unit: "g")  # 3 kg thon sur ~160 portions
add!(r, gruyere,       8,   unit: "g")  # 1.2 kg sur ~160 portions
add!(r, poudre_tomate, 5,   unit: "g")  # ~750 g total sur ~160 portions
add!(r, tomates,       25,  unit: "g")  # 4 kg tomates sur ~160 portions
add!(r, sauce_pizza,   5,   unit: "g")  # 800 g S.Pizza sur ~160 portions
add!(r, tartare_tomate, 10, unit: "g")  # 1.6 kg sur ~160 portions

# Quiche saumon asperges (photo IMG_8056)
puts "\n── Quiche saumon asperges ──"
r = upsert!(user, "Quiche saumon asperges", sub: false)
add!(r, pate_brisee,  124, unit: "g")
add!(r, saumon,       30,  unit: "g")
add!(r, asperges,     25,  unit: "g")
add!(r, sauce_quiche, 150, unit: "g")

# Quiche chèvre épinard (photo IMG_8056)
puts "\n── Quiche chèvre épinard ──"
r = upsert!(user, "Quiche chèvre épinard", sub: false)
add!(r, pate_brisee,  115, unit: "g")
add!(r, epinard,      35,  unit: "g")
add!(r, chevre,       30,  unit: "g")
add!(r, sauce_quiche, 160, unit: "g")

# ─────────────────────────────────────────────────────────────
# AUTRES RECETTES
# ─────────────────────────────────────────────────────────────

# Tagliatelle écrevisses (photo IMG_8064)
puts "\n── Tagliatelle écrevisses ──"
r = upsert!(user, "Tagliatelle écrevisses", sub: false)
add!(r, ecrevisses,   8,   unit: "kg")
add!(r, julienne,     3,   unit: "kg")
add!(r, creme,        4,   unit: "l")
add!(r, eau,          3,   unit: "l")
add!(r, ssc_ecrevisse, 400, unit: "g")
add!(r, sel,          100, unit: "g")
add!(r, poivre,       10,  unit: "g")
add!(r, piment,       1,   unit: "g")
add!(r, roux,         900, unit: "g")

# Choux farcis (photo IMG_8057)
puts "\n── Choux farcis ──"
r = upsert!(user, "Choux farcis", sub: false)
add!(r, huile_olive,   500,   unit: "g")
add!(r, oignons,       1.5,   unit: "kg")
add!(r, chair_saucisse, 3,    unit: "kg")
add!(r, chair_tomate,  2,     unit: "kg")
add!(r, tomates,       4,     unit: "kg")
add!(r, ail,           50,    unit: "g")
add!(r, sel,           40,    unit: "g")
add!(r, poivre,        40,    unit: "g")
add!(r, piment,        1,     unit: "g")
add!(r, sauce_pizza,   500,   unit: "g")
add!(r, chou,          40,    unit: "g")

# Fricassée de volaille (photo IMG_8058)
# Sauce base + assemblage : Sauce 1 kg + Blanc poulet 1 kg + Champignons 150 g
puts "\n── Fricassée de volaille ──"
r = upsert!(user, "Fricassée de volaille", sub: false)
add!(r, creme,         10,  unit: "l")
add!(r, lait,          4,   unit: "l")
add!(r, eau,           1.9, unit: "l")
add!(r, ssc_champign,  500, unit: "g")
add!(r, ssc_girolles,  100, unit: "g")
add!(r, ail,           100, unit: "g")
add!(r, echalote,      40,  unit: "g")
add!(r, sauce_pizza,   1,   unit: "kg")
add!(r, sel,           220, unit: "g")
add!(r, poivre,        20,  unit: "g")
add!(r, jus_champignon, 5,  unit: "l")
add!(r, champignons,   15,  unit: "kg")
add!(r, poulet,        1,   unit: "kg")

# Bolognaise (photo IMG_8090)
puts "\n── Bolognaise ──"
r = upsert!(user, "Bolognaise", sub: false)
add!(r, huile_olive,      3,   unit: "l")
add!(r, oignons,          10,  unit: "kg")
add!(r, carottes,         8,   unit: "kg")
add!(r, egrene_boeuf,     60,  unit: "kg")
add!(r, vin_blanc,        3,   unit: "l")
add!(r, concentre_tomate, 10,  unit: "kg")
add!(r, sauce_gustosa,    3,   unit: "piece")  # 3 boîtes
add!(r, fond_de_veau,     1.5, unit: "kg")
add!(r, persil,           1.5, unit: "kg")
add!(r, chocolat,         300, unit: "g")

# Croissants (photo IMG_8085)
puts "\n── Croissants ──"
r = upsert!(user, "Croissants", sub: false)
add!(r, farine,        50,   unit: "kg")
add!(r, margo,         6,    unit: "kg")
add!(r, beurre_trace,  6,    unit: "kg")
add!(r, sucre,         6.5,  unit: "kg")
add!(r, sel,           0.95, unit: "kg")
add!(r, levure,        3,    unit: "kg")
add!(r, oeufs_entiers, 4,    unit: "kg")   # 4 kg oeufs (indiqué en kg sur la fiche)
add!(r, eau,           10,   unit: "l")
add!(r, lait,          9,    unit: "l")
add!(r, sam_crois,     400,  unit: "g")

puts "\n#{'='*60}"
puts "✅ Étape 3 terminée"
puts "⚠️  Produits créés à 0€ → à pricer dans Produits"
puts "Points à vérifier manuellement :"
puts "  · Feuilleté jambon : quantité jambon à préciser (estimée à 100g)"
puts "  · Quiche légumes   : quantités julienne/gruyère estimées (proportionnel batch)"
puts "  · Quiche thon      : quantités estimées (proportionnel batch)"
puts "  · Croissants       : oeufs en kg (pas en pièces sur la fiche)"
puts "="*60
