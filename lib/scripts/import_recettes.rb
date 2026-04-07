# encoding: utf-8
# frozen_string_literal: true
# Import 59 recettes depuis Recettes 19 mars 26 (3).ods
# Utilise les noms DB existants pour éviter les doublons

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")
puts "=== Import recettes - #{user.email} ==="

# ============================================================
# HELPERS
# ============================================================

# Cherche un produit par pattern ILIKE, crée si fallback donné
def p!(user, *patterns, fallback: nil)
  patterns.each do |pat|
    prod = user.products.where("name ILIKE ?", pat).first
    return prod if prod
  end
  if fallback
    prod = user.products.find_or_create_by!(name: fallback)
    puts "  + produit: #{prod.name}"
    return prod
  end
  puts "  WARN produit introuvable: #{patterns.first}"
  nil
end

# Cherche une sous-recette par nom exact (insensible à la casse)
def sr!(user, name)
  r = user.recipes.where("name ILIKE ?", name).where(sellable_as_component: true).first
  puts "  WARN sous-recette introuvable: #{name}" unless r
  r
end

$skip_adds = false

# Crée une recette seulement si elle n'existe pas ou n'a pas de composants
# NE MODIFIE PAS les recettes existantes avec des composants
def upsert!(user, name, sub: false)
  r = user.recipes.where("name ILIKE ?", name).first
  if r && r.recipe_components.exists?
    $skip_adds = true
    puts "  SKIP (déjà configurée): #{name}"
    return r
  end
  $skip_adds = false
  r ||= user.recipes.new(name: name)
  r.name = name
  r.sellable_as_component = sub
  r.cooking_loss_percentage ||= 0
  r.save!
  r
end

# Ajoute un composant (produit ou sous-recette) à une recette
def add!(recipe, comp, qty, unit: "kg")
  return if $skip_adds
  return if comp.nil? || qty.to_f == 0
  recipe.recipe_components.create!(
    component: comp,
    quantity_kg: qty.to_f,
    quantity_unit: unit
  )
rescue ActiveRecord::RecordInvalid => e
  puts "  ERR #{recipe.name} <- #{comp&.name}: #{e.message}"
end

def recalc!(r)
  return if $skip_adds
  Recipes::Recalculator.call(r)
rescue => e
  puts "  WARN recalc #{r.name}: #{e.message}"
end

n = 0

# ============================================================
# SOUS-RECETTES NIVEAU 0 (sans dépendances inter-import)
# ============================================================

# --- Roux (exists) ---
r = upsert!(user, "Roux", sub: true)
add!(r, p!(user, "%margarine%"), 14)
add!(r, p!(user, "Beurre", fallback: "Beurre"), 10)
add!(r, p!(user, "%beurre trac%", fallback: "Beurre tracé"), 6)
add!(r, p!(user, "%farine%"), 31)
recalc!(r); n += 1; puts "✓ Roux"

# --- TPT (exists, DB name: "TPT") ---
r = upsert!(user, "TPT", sub: true)
add!(r, p!(user, "%sucre glace%", fallback: "Sucre glace"), 6)
add!(r, p!(user, "%poudre amande%", fallback: "Poudre amande blanche"), 4)
add!(r, p!(user, "%farine%"), 2)
add!(r, p!(user, "%levure%"), 0.1)
recalc!(r); n += 1; puts "✓ TPT"

# --- Sauce pizza (exists) ---
r = upsert!(user, "Sauce pizza", sub: true)
add!(r, p!(user, "Beurre", fallback: "Beurre"), 0.25)
add!(r, p!(user, "%huile%olive%", "%huile%"), 0.25)
add!(r, p!(user, "%pr_frit%", "%oignon%"), 1.5)
add!(r, p!(user, "%tomate%pel%", "%concass%", fallback: "Tomate pelée concassée"), 16.8) # 4 boites x 4.2 kg
add!(r, p!(user, "%sel%"), 0.2)
add!(r, p!(user, "%poivre%"), 0.01)
add!(r, p!(user, "%sucre semoule%", "%sucre%"), 0.5)  # 500 dans Excel = bug => 0.5 kg
add!(r, p!(user, "%origan%", fallback: "Origan"), 0.01)
add!(r, p!(user, "%concentr%tomate%", "%concentr%"), 0.6)
add!(r, sr!(user, "Roux"), 1)
recalc!(r); n += 1; puts "✓ Sauce pizza"

# --- Sauce quiche (exists) ---
r = upsert!(user, "Sauce quiche", sub: true)
add!(r, p!(user, "%lait%"), 10)
add!(r, p!(user, "%cr_me%"), 8)
add!(r, p!(user, "%cr_me%"), 2)  # crème épaisse -> même produit
add!(r, sr!(user, "Roux"), 1.3)
add!(r, p!(user, "%sel%"), 0.1)
add!(r, p!(user, "%poivre%"), 0.01)
add!(r, p!(user, "%muscade%", fallback: "Muscade"), 0.05)
add!(r, p!(user, "%oeuf%frais%", fallback: "Oeuf frais"), 100, unit: "piece")  # 100 oeufs
add!(r, p!(user, "%jaune%oeuf%", fallback: "Jaune d'oeuf"), 1)
recalc!(r); n += 1; puts "✓ Sauce quiche"

# --- Sauce feuilleté bleu (exists) ---
r = upsert!(user, "Sauce feuilleté bleu", sub: true)
add!(r, p!(user, "%lait%"), 3)
add!(r, p!(user, "%cr_me%"), 2)
add!(r, p!(user, "%bleu%"), 3)
add!(r, p!(user, "%noix%"), 0.25)
add!(r, sr!(user, "Roux"), 1.7)
add!(r, p!(user, "%poivre%"), 0.01)
recalc!(r); n += 1; puts "✓ Sauce feuilleté bleu"

# --- Sauce feuilleté saumon (exists, Excel: "Sauce saumon") ---
r = upsert!(user, "Sauce feuilleté saumon", sub: true)
add!(r, p!(user, "%saumon%"), 60)
add!(r, p!(user, "%sac%cuisson%", fallback: "Sac cuisson"), 24, unit: "piece")
add!(r, p!(user, "%fumet%poisson%", fallback: "Fumet de poisson"), 15)
add!(r, p!(user, "%lait%"), 30)
add!(r, p!(user, "%cr_me%"), 30)
add!(r, p!(user, "%vin blanc%", fallback: "Vin blanc"), 1.2)
add!(r, p!(user, "Eau", fallback: "Eau"), 0.8)
add!(r, p!(user, "%chalote%surgel%", "%chalot%"), 1)
add!(r, p!(user, "%fumet%crustac%", "%crustac%"), 0.8)
add!(r, p!(user, "%fumet%homard%", "%homard%"), 0.8)
add!(r, p!(user, "%fumet%crustac%", "%crustac%"), 0.4)
add!(r, p!(user, "%tomatina%"), 1)
add!(r, sr!(user, "Roux"), 11)
add!(r, p!(user, "%sel%"), 0.72)
add!(r, p!(user, "%poivre%"), 0.03)
recalc!(r); n += 1; puts "✓ Sauce feuilleté saumon"

# --- Béchamel feuilleté jambon (exists) ---
r = upsert!(user, "Béchamel feuilleté jambon", sub: true)
add!(r, p!(user, "%lait%"), 12)
add!(r, p!(user, "%cr_me%"), 8)
add!(r, sr!(user, "Roux"), 4.5)
add!(r, p!(user, "%picardan%", fallback: "Picardan"), 1)
add!(r, p!(user, "%sel%"), 0.2)
add!(r, p!(user, "%poivre%"), 0.01)
add!(r, p!(user, "%muscade%", fallback: "Muscade"), 0.05)
recalc!(r); n += 1; puts "✓ Béchamel feuilleté jambon"

# --- Sauce ris de veau louche (exists) ---
r = upsert!(user, "Sauce ris de veau louche", sub: true)
add!(r, p!(user, "Beurre", fallback: "Beurre"), 1)
add!(r, p!(user, "%chalote%hach%", "%chalot%"), 1)
add!(r, p!(user, "%morille%"), 4)
add!(r, p!(user, "%sac%cuisson%", fallback: "Sac cuisson"), 4, unit: "piece")
add!(r, p!(user, "%ris%veau%", fallback: "Ris de veau"), 40)
add!(r, p!(user, "%porto%", fallback: "Porto"), 2)
add!(r, sr!(user, "Sauce pizza"), 2)
add!(r, p!(user, "%cr_me%"), 28)
add!(r, p!(user, "%lait%"), 2)
add!(r, p!(user, "%cr_me%"), 2)  # crème épaisse
add!(r, p!(user, "%sel%"), 0.52)
add!(r, p!(user, "%poivre%"), 0.03)
add!(r, sr!(user, "Roux"), 4)
recalc!(r); n += 1; puts "✓ Sauce ris de veau louche"

# --- Sauce bolognaise (exists, Excel: "Bolognaise sous recette") ---
r = upsert!(user, "Sauce bolognaise", sub: true)
add!(r, p!(user, "%huile%olive%", "%huile%"), 3)
add!(r, p!(user, "%oignon%surgel%", "%oignon%"), 10)
add!(r, p!(user, "%carott%"), 8)
add!(r, p!(user, "Eau", fallback: "Eau"), 1)
add!(r, p!(user, "%grain%boeuf%", "%grain%"), 60)
add!(r, p!(user, "Eau", fallback: "Eau"), 15)
add!(r, p!(user, "%vin blanc%", fallback: "Vin blanc"), 3)
add!(r, p!(user, "%concentr%tomate%", "%concentr%"), 10)
add!(r, p!(user, "%gustoz%", fallback: "Gustoza"), 9)
add!(r, p!(user, "%fond%veau%"), 1.5)
add!(r, p!(user, "%sel%"), 0.8)
add!(r, p!(user, "%poivre%"), 0.04)
add!(r, p!(user, "%piment%"), 0.01)
add!(r, p!(user, "%chocolat%", fallback: "Chocolat"), 0.2)
add!(r, p!(user, "%persil%"), 1.5)
recalc!(r); n += 1; puts "✓ Sauce bolognaise"

# --- Sauce spaghetti (exists, Excel: "Sauce spaghetti sous recette") ---
r = upsert!(user, "Sauce spaghetti", sub: true)
add!(r, p!(user, "Eau", fallback: "Eau"), 1)
add!(r, p!(user, "Beurre", fallback: "Beurre"), 0.75)
add!(r, p!(user, "%sel%"), 0.03)
add!(r, p!(user, "%poivre%"), 0.005)
add!(r, sr!(user, "Sauce pizza"), 4.5)
add!(r, p!(user, "%concentr%tomate%", "%concentr%"), 0.1)
recalc!(r); n += 1; puts "✓ Sauce spaghetti"

# --- Gratin dauphinois (exists) ---
r = upsert!(user, "Gratin dauphinois", sub: true)
add!(r, p!(user, "%pomme%terre%", "%PDT%", fallback: "Pomme de terre"), 44)
add!(r, p!(user, "%cr_me%"), 12)
add!(r, p!(user, "%lait%"), 12)
add!(r, p!(user, "Beurre", fallback: "Beurre"), 0.5)
add!(r, p!(user, "%sel%"), 0.43)
add!(r, p!(user, "%poivre%"), 0.03)
add!(r, p!(user, "%muscade%", fallback: "Muscade"), 0.01)
add!(r, p!(user, "%ail%"), 0.5)
recalc!(r); n += 1; puts "✓ Gratin dauphinois"

# --- Purée (exists) ---
r = upsert!(user, "Purée", sub: true)
add!(r, p!(user, "Eau", fallback: "Eau"), 1.5)
add!(r, p!(user, "%cr_me%"), 0.5)
add!(r, p!(user, "Beurre", fallback: "Beurre"), 0.15)
add!(r, p!(user, "%poudre%pur%", fallback: "Poudre purée"), 0.4)
recalc!(r); n += 1; puts "✓ Purée"

# --- Aligot (NOUVEAU) ---
r = upsert!(user, "Aligot", sub: true)
add!(r, p!(user, "%aligot%", fallback: "Aligot"), 2)
add!(r, p!(user, "Eau", fallback: "Eau"), 0.7)
add!(r, p!(user, "%cr_me%"), 0.3)
add!(r, p!(user, "%ail%"), 0.02)
add!(r, p!(user, "%poudre%pur%", fallback: "Poudre purée"), 0.08)
add!(r, p!(user, "%poivre%"), 0.004)
add!(r, p!(user, "%muscade%", fallback: "Muscade"), 0.001)
recalc!(r); n += 1; puts "✓ Aligot"

# --- Beurre escargot (exists) ---
r = upsert!(user, "Beurre escargot", sub: true)
add!(r, p!(user, "%persil%"), 0.75)
add!(r, p!(user, "%chalote%hach%", "%chalot%"), 0.12)
add!(r, p!(user, "%ail%"), 0.12)
add!(r, p!(user, "%sel%"), 0.15)
add!(r, p!(user, "%poivre%"), 0.01)
add!(r, p!(user, "%thym%", fallback: "Thym"), 0.006)
add!(r, p!(user, "%muscade%", fallback: "Muscade"), 0.006)
add!(r, p!(user, "%noix%"), 0.2)
add!(r, p!(user, "%anchois%", fallback: "Anchois"), 0.15)
add!(r, p!(user, "%ricard%", fallback: "Ricard"), 0.1)
add!(r, p!(user, "Beurre", fallback: "Beurre"), 6)
recalc!(r); n += 1; puts "✓ Beurre escargot"

# --- Sauce Saint Jacques (NOUVEAU) ---
r = upsert!(user, "Sauce Saint Jacques", sub: true)
add!(r, p!(user, "Beurre", fallback: "Beurre"), 0.5)
add!(r, p!(user, "%chalote%hach%", "%chalot%"), 1)
add!(r, p!(user, "%vin blanc%", fallback: "Vin blanc"), 2)
add!(r, p!(user, "%vermouth%", fallback: "Vermouth"), 2)
recalc!(r); n += 1; puts "✓ Sauce Saint Jacques"

# --- Poireaux (exists, Excel: "Poireaux sous recette") ---
r = upsert!(user, "Poireaux", sub: true)
add!(r, p!(user, "%poireau%"), 50)
add!(r, p!(user, "%beurre trac%", fallback: "Beurre tracé"), 1)
add!(r, p!(user, "%sel%"), 0.5)
add!(r, p!(user, "%sucre semoule%", "%sucre%"), 0.6)
recalc!(r); n += 1; puts "✓ Poireaux"

# --- Légumes sous recette (exists) ---
r = upsert!(user, "Légumes sous recette", sub: true)
add!(r, p!(user, "%julienne%", fallback: "Julienne de légumes surgelés"), 5)
add!(r, p!(user, "%gruy_re%", fallback: "Gruyère"), 1)
add!(r, p!(user, "%sel%"), 0.03)
add!(r, p!(user, "%poivre%"), 0.03)
recalc!(r); n += 1; puts "✓ Légumes sous recette"

# --- Mayonnaise (exists, Excel: "mayonnaise sous recette") ---
r = upsert!(user, "Mayonnaise", sub: true)
add!(r, p!(user, "%jaune%oeuf%", fallback: "Jaune d'oeuf"), 2)
add!(r, p!(user, "%moutarde%"), 1)
add!(r, p!(user, "%sel%"), 0.1)
add!(r, p!(user, "%poivre%"), 0.01)
add!(r, p!(user, "%vinaigre%"), 0.3)
add!(r, p!(user, "%huile%"), 12.5)
recalc!(r); n += 1; puts "✓ Mayonnaise"

# --- Vinaigrette (exists, Excel: "Vinaigrette sous recette") ---
r = upsert!(user, "Vinaigrette", sub: true)
add!(r, p!(user, "%huile%"), 3.5)
add!(r, p!(user, "%huile%olive%", "%huile%"), 0.5)
add!(r, p!(user, "%vinaigre%vin%", "%vinaigre%"), 1.2)
add!(r, p!(user, "%balsamique%"), 0.4)
add!(r, p!(user, "%moutarde%"), 1)
add!(r, p!(user, "%persillade%"), 0.01)
add!(r, p!(user, "%sel%"), 0.1)
add!(r, p!(user, "%poivre%"), 0.02)
add!(r, p!(user, "%mayonnaise%", "%mayonnal%"), 0.2)
add!(r, p!(user, "Eau", fallback: "Eau"), 4)
recalc!(r); n += 1; puts "✓ Vinaigrette"

# --- Vinaigrette balsamique (exists, Excel: "vinaigrette balsamique sous recette") ---
r = upsert!(user, "Vinaigrette balsamique", sub: true)
add!(r, p!(user, "%huile%"), 4)
add!(r, p!(user, "%balsamique%"), 2)
add!(r, p!(user, "%moutarde%"), 0.4)
add!(r, p!(user, "%mayonnaise%", "%mayonnal%"), 0.15)
add!(r, p!(user, "%sel%"), 0.07)
add!(r, p!(user, "%poivre%"), 0.01)
add!(r, p!(user, "Eau", fallback: "Eau"), 4)
recalc!(r); n += 1; puts "✓ Vinaigrette balsamique"

# --- Vinaigrette carottes rapées (exists, Excel: "vinaigrette carottes rappées sous recette") ---
r = upsert!(user, "Vinaigrette carottes rapées", sub: true)
add!(r, p!(user, "%huile%"), 3.5)
add!(r, p!(user, "%huile%olive%", "%huile%"), 0.5)
add!(r, p!(user, "%vinaigre%vin%", "%vinaigre%"), 2.2)
add!(r, p!(user, "%balsamique%"), 0.6)
add!(r, p!(user, "%moutarde%"), 1)
add!(r, p!(user, "%persillade%"), 0.02)
add!(r, p!(user, "%sel%"), 0.2)
add!(r, p!(user, "%poivre%"), 0.02)
add!(r, p!(user, "%mayonnaise%", "%mayonnal%"), 0.3)
add!(r, p!(user, "Eau", fallback: "Eau"), 4)
add!(r, p!(user, "%citron%"), 0.6)
recalc!(r); n += 1; puts "✓ Vinaigrette carottes rapées"

# --- Jus de fruit (exists, Excel: "jus de fruit sous recette") ---
r = upsert!(user, "Jus de fruit", sub: true)
add!(r, p!(user, "%coulis%framboise%", "%framboise%"), 1)
add!(r, p!(user, "%sucre semoule%", "%sucre%"), 0.15)
add!(r, p!(user, "Eau", fallback: "Eau"), 3)
recalc!(r); n += 1; puts "✓ Jus de fruit"

# --- Pâte à pompe (exists, DB name: "Pâte à pompe") ---
r = upsert!(user, "Pâte à pompe", sub: true)
add!(r, p!(user, "%farine%"), 50)
add!(r, p!(user, "Beurre", fallback: "Beurre"), 12)
add!(r, p!(user, "%beurre trac%", fallback: "Beurre tracé"), 7)
add!(r, p!(user, "%margarine%"), 6)
add!(r, p!(user, "%sucre semoule%", "%sucre%"), 16)
add!(r, p!(user, "%sel%"), 0.3)
add!(r, p!(user, "%huile%"), 2.5)
add!(r, p!(user, "Eau", fallback: "Eau"), 10)
recalc!(r); n += 1; puts "✓ Pâte à pompe"

# --- Pate sucree (exists, DB name: "Pate sucree") ---
r = upsert!(user, "Pate sucree", sub: true)
add!(r, p!(user, "%farine%"), 30)
add!(r, p!(user, "Beurre", fallback: "Beurre"), 15)
add!(r, p!(user, "%sucre glace%", fallback: "Sucre glace"), 14.5)
add!(r, p!(user, "%f_cule%", fallback: "Fécule"), 8)
add!(r, p!(user, "%poudre amande%grise%", "%poudre amande%"), 4.5)
add!(r, p!(user, "%sel%"), 0.2)
add!(r, p!(user, "%oeuf%frais%", fallback: "Oeuf frais"), 9)
add!(r, p!(user, "%vanille%", fallback: "Vanille"), 0.1)
recalc!(r); n += 1; puts "✓ Pate sucree"

# --- Pate a pizza (exists, DB name: "Pate a pizza") ---
r = upsert!(user, "Pate a pizza", sub: true)
add!(r, p!(user, "%farine%"), 50)
add!(r, p!(user, "%sel%"), 1)
add!(r, p!(user, "%sucre semoule%", "%sucre%"), 2.5)
add!(r, p!(user, "%oeuf%frais%", fallback: "Oeuf frais"), 9)
add!(r, p!(user, "%levure%"), 2.5)
add!(r, p!(user, "Eau", fallback: "Eau"), 6)
add!(r, p!(user, "%lait%"), 6)
add!(r, p!(user, "%huile%olive%", "%huile%"), 1)
add!(r, p!(user, "%beurre trac%", fallback: "Beurre tracé"), 7)
add!(r, p!(user, "%margarine%"), 6)
recalc!(r); n += 1; puts "✓ Pate a pizza"

# --- Pâte à pâté en croûte (exists) ---
r = upsert!(user, "Pâte à pâté en croûte", sub: true)
add!(r, p!(user, "%farine%"), 42)
add!(r, p!(user, "%sel%"), 0.84)
add!(r, p!(user, "%sucre semoule%", "%sucre%"), 0.84)
add!(r, p!(user, "Beurre", fallback: "Beurre"), 3.5)
add!(r, p!(user, "%beurre trac%", fallback: "Beurre tracé"), 14)
add!(r, p!(user, "%oeuf%frais%", fallback: "Oeuf frais"), 7)
add!(r, p!(user, "%cognac%", fallback: "Cognac"), 7)
recalc!(r); n += 1; puts "✓ Pâte à pâté en croûte"

# --- Pâte à pâté en croûte ** (NOUVEAU - variante) ---
r = upsert!(user, "Pâte à pâté en croûte **", sub: true)
add!(r, p!(user, "%farine%"), 42)
add!(r, p!(user, "%sel%"), 0.84)
add!(r, p!(user, "%sucre semoule%", "%sucre%"), 0.84)
add!(r, p!(user, "Beurre", fallback: "Beurre"), 3.5)
add!(r, p!(user, "%beurre trac%", fallback: "Beurre tracé"), 14)
add!(r, p!(user, "%oeuf%frais%", fallback: "Oeuf frais"), 7)
add!(r, p!(user, "%cognac%", fallback: "Cognac"), 7)
recalc!(r); n += 1; puts "✓ Pâte à pâté en croûte **"

# --- Pate à croissant (NOUVEAU) ---
r = upsert!(user, "Pate à croissant", sub: true)
add!(r, p!(user, "%farine%"), 50)
add!(r, p!(user, "%margarine%"), 6)
add!(r, p!(user, "%beurre trac%", fallback: "Beurre tracé"), 6)
add!(r, p!(user, "%sucre semoule%", "%sucre%"), 6.5)
add!(r, p!(user, "%sel%"), 0.95)
add!(r, p!(user, "%levure%"), 3)
add!(r, p!(user, "%oeuf%frais%", fallback: "Oeuf frais"), 4)
add!(r, p!(user, "Eau", fallback: "Eau"), 10)
add!(r, p!(user, "%lait%"), 9)
add!(r, p!(user, "%am_liorant%", fallback: "Améliorant"), 0.4)
add!(r, p!(user, "%margarine%"), 24)  # beurre plaque -> margarine
recalc!(r); n += 1; puts "✓ Pate à croissant"

# ============================================================
# SOUS-RECETTES NIVEAU 1 (dépendent de niveau 0)
# ============================================================

# --- Sauce fruits de mer (NOUVEAU) ---
r = upsert!(user, "Sauce fruits de mer", sub: true)
add!(r, p!(user, "%moule%"), 9)
add!(r, p!(user, "%crevett%d_cort%", "%crevett%"), 6)
add!(r, p!(user, "%_crevisse%"), 4)
add!(r, p!(user, "%p_toncle%", fallback: "Noix de pétoncle"), 3)
add!(r, p!(user, "%champignon%"), 1, unit: "piece")
add!(r, p!(user, "%vin blanc%", fallback: "Vin blanc"), 1)
add!(r, p!(user, "%chalote%hach%", "%chalot%"), 0.5)
add!(r, p!(user, "%saumon%"), 7.5)
add!(r, p!(user, "%merlan%", fallback: "Merlan"), 7.5)
add!(r, p!(user, "%quenelle%broch%", fallback: "Quenelles de brochet"), 2)
add!(r, p!(user, "%lait%"), 20)
add!(r, p!(user, "%cr_me%"), 13)
add!(r, p!(user, "%fumet%poisson%", fallback: "Fumet de poisson"), 8)
add!(r, p!(user, "%fumet%crustac%", "%crustac%"), 0.4)
add!(r, p!(user, "%fumet%homard%", "%homard%"), 0.4)
add!(r, sr!(user, "Roux"), 9)
add!(r, p!(user, "%sel%"), 0.3)
recalc!(r); n += 1; puts "✓ Sauce fruits de mer"

# --- Sauce Feuilleté ris de veau (NOUVEAU) ---
r = upsert!(user, "Sauce Feuilleté ris de veau", sub: true)
add!(r, p!(user, "%ris%veau%", fallback: "Ris de veau cuit"), 60)
add!(r, p!(user, "%morille%"), 5.75)
add!(r, p!(user, "Eau", fallback: "Eau"), 15)
add!(r, p!(user, "%sel%"), 0.1)
add!(r, p!(user, "Beurre", fallback: "Beurre"), 1.5)
add!(r, p!(user, "%chalote%surgel%", "%chalot%"), 2)
add!(r, p!(user, "%porto%", fallback: "Porto"), 3)
add!(r, p!(user, "%sauce%morille%"), 0.6)
add!(r, sr!(user, "Sauce pizza"), 1.5)
add!(r, p!(user, "%lait%"), 40)
add!(r, p!(user, "%cr_me%"), 36)
add!(r, sr!(user, "Roux"), 22)
add!(r, p!(user, "%sel%"), 0.95)
add!(r, p!(user, "%poivre%"), 0.4)
add!(r, p!(user, "%sac%cuisson%", fallback: "Sac cuisson"), 24, unit: "piece")
recalc!(r); n += 1; puts "✓ Sauce Feuilleté ris de veau"

# --- Sauce Feuilleté poulet (NOUVEAU) ---
r = upsert!(user, "Sauce Feuilleté poulet", sub: true)
add!(r, p!(user, "%blanc%poulet%", fallback: "Blanc de poulet"), 62.5)
add!(r, p!(user, "%sac%cuisson%", fallback: "Sac cuisson"), 25, unit: "piece")
add!(r, p!(user, "%morille%"), 11.5)
add!(r, p!(user, "Beurre", fallback: "Beurre"), 1.5)
add!(r, p!(user, "%chalote%surgel%", "%chalot%"), 1.5)
add!(r, p!(user, "%pulpe%chalot%", "%chalot%"), 0.5)
add!(r, p!(user, "Eau", fallback: "Eau"), 12)
add!(r, p!(user, "%sel%"), 0.1)
add!(r, p!(user, "%lait%"), 48)
add!(r, p!(user, "%cr_me%"), 36)
add!(r, p!(user, "%sauce%girolle%"), 1.6)   # 2 pots x 0.8 kg
add!(r, p!(user, "%sauce%champignon%"), 0.9) # 1 pot x 0.9 kg
add!(r, p!(user, "%vin blanc%", fallback: "Vin blanc"), 2)
add!(r, p!(user, "%tomatina%"), 5.0)         # 2 boites x 2.5 kg
add!(r, sr!(user, "Roux"), 24.5)
add!(r, p!(user, "%sel%"), 0.95)
add!(r, p!(user, "%poivre%"), 0.05)
recalc!(r); n += 1; puts "✓ Sauce Feuilleté poulet"

# --- Feuilleté écrevisse (NOUVEAU) ---
r = upsert!(user, "Feuilleté écrevisse", sub: true)
add!(r, p!(user, "%_crevisse%"), 8)
add!(r, sr!(user, "Légumes sous recette"), 4)
add!(r, p!(user, "Eau", fallback: "Eau"), 2.5)
add!(r, p!(user, "%vin blanc%", fallback: "Vin blanc"), 0.5)
add!(r, p!(user, "%cr_me%"), 6)
add!(r, p!(user, "%lait%"), 2)
add!(r, p!(user, "%fumet%crustac%", "%crustac%"), 0.4)
add!(r, p!(user, "%fumet%langoustine%", "%langoustine%"), 0.1)
add!(r, sr!(user, "Sauce pizza"), 0.5)
add!(r, sr!(user, "Roux"), 2.5)
recalc!(r); n += 1; puts "✓ Feuilleté écrevisse"

# --- Frangipane (exists) ---
r = upsert!(user, "Frangipane", sub: true)
add!(r, sr!(user, "TPT"), 4.2)
add!(r, p!(user, "%blanc%oeuf%"), 2)
add!(r, p!(user, "Beurre", fallback: "Beurre"), 1.5)
recalc!(r); n += 1; puts "✓ Frangipane"

# --- Carottes rapées (exists, Excel: "Carottes rapées sous recette") ---
r = upsert!(user, "Carottes rapées", sub: true)
add!(r, p!(user, "%carott%"), 1.3)
add!(r, sr!(user, "Vinaigrette carottes rapées"), 0.25)
recalc!(r); n += 1; puts "✓ Carottes rapées"

# ============================================================
# RECETTES PRINCIPALES
# ============================================================

# --- Brioche aux grattons ---
r = upsert!(user, "Brioche aux grattons")
add!(r, p!(user, "%graton%", fallback: "Gratons"), 5)
add!(r, p!(user, "%farine%"), 5.2)
add!(r, p!(user, "%sel%"), 0.1)
add!(r, p!(user, "%sucre semoule%", "%sucre%"), 0.25)
add!(r, p!(user, "%levure%"), 0.7)
add!(r, p!(user, "%oeuf%frais%", fallback: "Oeuf frais"), 50, unit: "piece")
add!(r, p!(user, "%beurre trac%", fallback: "Beurre tracé"), 1)
add!(r, p!(user, "Beurre", fallback: "Beurre"), 1.5)
add!(r, p!(user, "%am_liorant%", fallback: "Améliorant"), 0.2)
recalc!(r); n += 1; puts "✓ Brioche aux grattons"

# --- Feuilletés 4 portions ---
r = upsert!(user, "Feuilletés 4 portions")
add!(r, sr!(user, "Pâte Feuilletée"), 0.42)
add!(r, p!(user, "%sauce%", fallback: "Sauces"), 0.5)
recalc!(r); n += 1; puts "✓ Feuilletés 4 portions"

# --- Feuilletés 6 portions ---
r = upsert!(user, "Feuilletés 6 portions")
add!(r, sr!(user, "Pâte Feuilletée"), 0.55)
add!(r, p!(user, "%sauce%", fallback: "Sauces"), 0.8)
recalc!(r); n += 1; puts "✓ Feuilletés 6 portions"

# --- Feuilleté 8 personnes ---
r = upsert!(user, "Feuilleté 8 personnes")
add!(r, sr!(user, "Pâte Feuilletée"), 0.7)
add!(r, p!(user, "%sauce%", fallback: "Sauces"), 1.2)
recalc!(r); n += 1; puts "✓ Feuilleté 8 personnes"

# --- Paté pomme de terre 4 portions ---
r = upsert!(user, "Paté pomme de terre 4 portions")
add!(r, sr!(user, "Pâte Feuilletée"), 0.35)
add!(r, sr!(user, "Gratin dauphinois"), 0.55)
add!(r, p!(user, "%ail%"), 0.005)
add!(r, p!(user, "%chalote%hach%", "%chalot%"), 0.005)
add!(r, p!(user, "%persil%"), 0.005)
add!(r, p!(user, "%cr_me%"), 0.04)
recalc!(r); n += 1; puts "✓ Paté pomme de terre 4 portions"

# --- Paté pomme de terre 2 portions ---
r = upsert!(user, "Paté pomme de terre 2 portions")
add!(r, sr!(user, "Gratin dauphinois"), 0.275)
add!(r, p!(user, "%ail%"), 0.0025)
add!(r, p!(user, "%chalote%hach%", "%chalot%"), 0.0025)
add!(r, p!(user, "%persil%"), 0.0025)
add!(r, p!(user, "%cr_me%"), 0.02)
recalc!(r); n += 1; puts "✓ Paté pomme de terre 2 portions"

# --- Tarte aux myrtilles ---
r = upsert!(user, "Tarte aux myrtilles")
add!(r, sr!(user, "Pate sucree"), 1.3)
add!(r, sr!(user, "Frangipane"), 0.9)
add!(r, p!(user, "%myrtille%", fallback: "Myrtilles"), 2)
add!(r, p!(user, "%nappage%", fallback: "Nappage"), 0.7)
recalc!(r); n += 1; puts "✓ Tarte aux myrtilles"

# --- Ris de veau aux morilles louche barquette ---
r = upsert!(user, "Ris de veau aux morilles louche barquette")
add!(r, p!(user, "%barquette%"), 1, unit: "piece")
add!(r, sr!(user, "Sauce ris de veau louche"), 0.25)
recalc!(r); n += 1; puts "✓ Ris de veau aux morilles louche barquette"

# --- Spaghetti bolognaise Barquette ---
r = upsert!(user, "Spaghetti bolognaise Barquette")
add!(r, p!(user, "%barquette%"), 1, unit: "piece")
add!(r, p!(user, "%spaghetti%"), 0.245)
add!(r, sr!(user, "Sauce bolognaise"), 0.1)
recalc!(r); n += 1; puts "✓ Spaghetti bolognaise Barquette"

# --- Parmentier de canard Barquette ---
r = upsert!(user, "Parmentier de canard Barquette")
add!(r, p!(user, "%barquette%"), 1, unit: "piece")
add!(r, sr!(user, "Purée"), 0.25)
add!(r, p!(user, "%canard%", fallback: "Canard"), 0.1)
recalc!(r); n += 1; puts "✓ Parmentier de canard Barquette"

# --- Tagliatelle écrevisses ---
r = upsert!(user, "Tagliatelle écrevisses")
add!(r, p!(user, "%_crevisse%"), 8)
add!(r, sr!(user, "Légumes sous recette"), 3)
add!(r, p!(user, "%cr_me%"), 4)
add!(r, p!(user, "Eau", fallback: "Eau"), 3)
add!(r, p!(user, "%sauce%_crevisse%", "%_crevisse%"), 0.4)
add!(r, p!(user, "%sel%"), 0.1)
add!(r, p!(user, "%poivre%"), 0.01)
add!(r, p!(user, "%piment%"), 0.001)
add!(r, sr!(user, "Roux"), 0.9)
recalc!(r); n += 1; puts "✓ Tagliatelle écrevisses"

# --- Fricassé de volaille ---
r = upsert!(user, "Fricassé de volaille")
add!(r, p!(user, "%cr_me%"), 10)
add!(r, p!(user, "%lait%"), 4)
add!(r, p!(user, "Eau", fallback: "Eau"), 6)
add!(r, sr!(user, "Roux"), 1.8)
add!(r, p!(user, "%sauce%champignon%"), 0.5)
add!(r, p!(user, "%sauce%girolle%"), 0.5)
add!(r, p!(user, "%ail%"), 0.1)
add!(r, p!(user, "%chalote%hach%", "%chalot%"), 0.1)
add!(r, p!(user, "%persil%"), 0.04)
add!(r, sr!(user, "Sauce pizza"), 1)
add!(r, p!(user, "%sel%"), 0.22)
add!(r, p!(user, "%poivre%"), 0.02)
add!(r, p!(user, "%jus%champignon%", fallback: "Jus de champignon"), 5)
add!(r, p!(user, "%sac%cuisson%", fallback: "Sac cuisson"), 26, unit: "piece")
add!(r, p!(user, "%blanc%poulet%", fallback: "Blanc de poulet"), 1)
add!(r, p!(user, "%champignon%"), 0.15)
recalc!(r); n += 1; puts "✓ Fricassé de volaille"

# --- Choux farcis ---
r = upsert!(user, "Choux farcis")
add!(r, p!(user, "%huile%"), 0.5)
add!(r, p!(user, "%oignon%"), 1.5)
add!(r, p!(user, "%chair%saucisse%", fallback: "Chair à saucisse"), 3)
add!(r, p!(user, "%tomate%concass%", "%tomate%"), 2)  # chair tomate
add!(r, p!(user, "%tomate%"), 4)
add!(r, p!(user, "%ail%"), 0.05)
add!(r, p!(user, "%sel%"), 0.04)
add!(r, p!(user, "%poivre%"), 0.04)
add!(r, p!(user, "%piment%"), 0.001)
add!(r, sr!(user, "Sauce pizza"), 0.5)
add!(r, p!(user, "%chou%"), 0.04)
recalc!(r); n += 1; puts "✓ Choux farcis"

# --- Salade de fruit ---
r = upsert!(user, "Salade de fruit")
add!(r, sr!(user, "Jus de fruit"), 0.05)
add!(r, p!(user, "%banane%", fallback: "Banane"), 0.04)
add!(r, p!(user, "%pomme%"), 0.04)
add!(r, p!(user, "%ananas%", fallback: "Ananas"), 0.04)
add!(r, p!(user, "%cl_mentine%", fallback: "Clémentine"), 0.04)
add!(r, p!(user, "%raisin%", fallback: "Raisin"), 0.04)
add!(r, p!(user, "%fraise%"), 0.04)
add!(r, p!(user, "%bol%", fallback: "Bol"), 1, unit: "piece")
recalc!(r); n += 1; puts "✓ Salade de fruit"

# --- Fromage blanc ---
r = upsert!(user, "Fromage blanc")
add!(r, p!(user, "%bol%", fallback: "Bol"), 1, unit: "piece")
add!(r, p!(user, "%fromage blanc%", fallback: "Fromage blanc"), 0.18)
add!(r, p!(user, "%kiwi%", fallback: "Kiwi"), 0.33)
add!(r, p!(user, "%cl_mentine%", fallback: "Clémentine"), 0.016)
add!(r, p!(user, "%fraise%"), 0.015)
add!(r, p!(user, "%nougat%", fallback: "Brisure de nougat"), 0.02)
recalc!(r); n += 1; puts "✓ Fromage blanc"

# --- Choux carottes ---
r = upsert!(user, "Choux carottes")
add!(r, p!(user, "%carott%"), 1)
add!(r, sr!(user, "Mayonnaise"), 0.5)
add!(r, p!(user, "%vinaigre%"), 0.05)
add!(r, p!(user, "%chou%"), 0.5)
add!(r, p!(user, "%ketchup%", fallback: "Ketchup"), 0.05)
add!(r, p!(user, "%poivre%"), 0.005)
recalc!(r); n += 1; puts "✓ Choux carottes"

# --- Macédoine ---
r = upsert!(user, "Macédoine")
add!(r, p!(user, "%mac_doine%", fallback: "Macédoine de légumes"), 1.25)
add!(r, sr!(user, "Mayonnaise"), 0.25)
add!(r, p!(user, "%sel%"), 0.02)
recalc!(r); n += 1; puts "✓ Macédoine"

# --- Haricots verts ---
r = upsert!(user, "Haricots verts")
add!(r, p!(user, "%haricot%"), 1.3)
add!(r, p!(user, "%persillade%"), 0.05)
add!(r, sr!(user, "Vinaigrette balsamique"), 0.15)
recalc!(r); n += 1; puts "✓ Haricots verts"

# --- Piemontaise ---
r = upsert!(user, "Piemontaise")
add!(r, p!(user, "%pomme%terre%", "%PDT%", fallback: "Pomme de terre"), 1.25)
add!(r, p!(user, "%persillade%"), 0.05)
add!(r, p!(user, "%oeuf%frais%", fallback: "Oeuf frais"), 3, unit: "piece")
add!(r, p!(user, "%tartare%tomate%", "%tartare%"), 0.05)
add!(r, p!(user, "%cornichon%", fallback: "Cornichons"), 0.05)
add!(r, sr!(user, "Mayonnaise"), 0.25)
add!(r, p!(user, "%vinaigre%"), 0.05)
add!(r, p!(user, "%jambon%"), 0.02)
recalc!(r); n += 1; puts "✓ Piemontaise"

# --- Pommes de terre ---
r = upsert!(user, "Pommes de terre")
add!(r, p!(user, "%pomme%terre%", "%PDT%", fallback: "Pomme de terre"), 1.25)
add!(r, p!(user, "%persillade%"), 0.02)
add!(r, p!(user, "%oeuf%frais%", fallback: "Oeuf frais"), 3, unit: "piece")
add!(r, p!(user, "%tartare%tomate%", "%tartare%"), 0.05)
add!(r, p!(user, "%cornichon%", fallback: "Cornichons"), 0.05)
add!(r, p!(user, "%vinaigre%"), 0.15)
recalc!(r); n += 1; puts "✓ Pommes de terre"

# --- Poulet pâtes ---
r = upsert!(user, "Poulet pâtes")
add!(r, p!(user, "%pates%couleur%", "%pates%trois%", fallback: "Pâtes trois couleurs"), 1.2)
add!(r, p!(user, "%blanc%poulet%", fallback: "Blanc de poulet"), 0.15)
add!(r, p!(user, "%tartare%tomate%", "%tartare%"), 0.05)
add!(r, p!(user, "%pr_frit%", "%oignon%"), 0.05)
add!(r, sr!(user, "Vinaigrette"), 0.25)
recalc!(r); n += 1; puts "✓ Poulet pâtes"

# --- Riz niçois ---
r = upsert!(user, "Riz niçois")
add!(r, p!(user, "%riz%tha%", fallback: "Riz thaï"), 0.5)
add!(r, p!(user, "%basmati%", fallback: "Riz Basmati"), 0.5)
add!(r, p!(user, "%poivron%"), 0.1)
add!(r, p!(user, "%ma_s%", fallback: "Maïs"), 0.15)
add!(r, p!(user, "%olive%"), 0.05)
add!(r, p!(user, "%thon%"), 0.3)
add!(r, p!(user, "%vinaigre%"), 0.2)
recalc!(r); n += 1; puts "✓ Riz niçois"

# --- Océance ---
r = upsert!(user, "Océance")
add!(r, p!(user, "%riz%tha%", fallback: "Riz thaï"), 0.5)
add!(r, p!(user, "%basmati%", fallback: "Riz Basmati"), 0.5)
add!(r, p!(user, "%poivron%"), 0.1)
add!(r, p!(user, "%crevett%d_cort%", "%crevett%"), 0.3)
add!(r, p!(user, "%surimi%"), 0.25)
add!(r, p!(user, "%mayonnaise%"), 0.5)
add!(r, p!(user, "%ketchup%", fallback: "Ketchup"), 0.05)
recalc!(r); n += 1; puts "✓ Océance"

# --- Lentilles ---
r = upsert!(user, "Lentilles")
add!(r, p!(user, "%lentille%", fallback: "Lentilles"), 1.5)
add!(r, p!(user, "%ma_s%", fallback: "Maïs"), 0.2)
add!(r, p!(user, "%tartare%tomate%", "%tartare%"), 0.05)
add!(r, p!(user, "%vinaigre%"), 0.15)
recalc!(r); n += 1; puts "✓ Lentilles"

# --- Melon ---
r = upsert!(user, "Melon")
add!(r, p!(user, "%melon%"), 3, unit: "piece")
add!(r, p!(user, "%tomate%cerise%", "%cerise%"), 0.5)
add!(r, p!(user, "%mozza%"), 0.65)
add!(r, p!(user, "%oignon%rouge%", fallback: "Oignon rouge"), 0.1)
add!(r, p!(user, "%sel%"), 0.006)
add!(r, p!(user, "%poivre%"), 0.006)
add!(r, p!(user, "%piment%espelette%", "%piment%"), 0.002)
add!(r, p!(user, "%menthe%", fallback: "Menthe fraîche"), 0.03)
add!(r, p!(user, "%huile%olive%", "%huile%"), 0.1)
add!(r, p!(user, "%balsamique%"), 0.012)
add!(r, p!(user, "%citron%"), 0.008)
recalc!(r); n += 1; puts "✓ Melon"

# --- Fromage blanc est déjà fait ci-dessus ---

puts "\n=== TERMINÉ : #{n} recettes créées/mises à jour ==="
