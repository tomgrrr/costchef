# encoding: utf-8
# frozen_string_literal: true
# Corrige les recettes abîmées par l'import :
# 1. Remplace "Beurre" (ID créé à 0€) par "Beurre motte" (ID 1109) partout
# 2. Corrige les 7 quantités perdues (doublons dans la même recette)
# 3. Supprime le produit fantôme "Beurre" à 0€

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")
puts "=== Fix import beurre - #{user.email} ==="

beurre_fantome = user.products.find_by(name: "Beurre")
beurre_motte   = user.products.find(1109)

unless beurre_fantome
  puts "Produit 'Beurre' introuvable - déjà corrigé ?"
  exit
end

puts "Beurre fantôme : ID #{beurre_fantome.id} (#{beurre_fantome.avg_price_per_kg} €/kg)"
puts "Beurre motte   : ID #{beurre_motte.id} (#{beurre_motte.avg_price_per_kg} €/kg)"

# ============================================================
# 1. Remplacer beurre fantôme → beurre motte dans tous les composants
# ============================================================
composants = RecipeComponent.where(component_type: "Product", component_id: beurre_fantome.id)
puts "\n#{composants.count} composants à corriger :"
composants.each do |rc|
  puts "  #{rc.parent_recipe.name} : #{rc.quantity_kg} kg"
  rc.update!(component_id: beurre_motte.id)
end
puts "✓ Beurre remplacé par Beurre motte"

# ============================================================
# 2. Supprimer le produit fantôme "Beurre"
# ============================================================
beurre_fantome.destroy!
puts "✓ Produit 'Beurre' (0€) supprimé"

# ============================================================
# 3. Corriger les 7 quantités perdues (composant dupliqué)
# ============================================================

def fix_qty!(recipe, product_or_recipe, add_qty, label)
  comp_type = product_or_recipe.is_a?(Recipe) ? "Recipe" : "Product"
  rc = RecipeComponent.where(parent_recipe_id: recipe.id,
                              component_type: comp_type,
                              component_id: product_or_recipe.id).first
  unless rc
    puts "  WARN #{label} introuvable dans #{recipe.name}"
    return
  end
  old = rc.quantity_kg
  rc.update!(quantity_kg: old + add_qty)
  puts "  #{recipe.name} | #{label} : #{old} + #{add_qty} = #{rc.quantity_kg} kg"
end

puts "\n=== Correction des quantités perdues ==="

creme = user.products.where("name ILIKE ?", "%cr_me%").first

# Sauce quiche : crème épaisse 2L perdue
r = user.recipes.find_by("name ILIKE ?", "Sauce quiche")
fix_qty!(r, creme, 2, "Crème") if r && creme

# Sauce feuilleté saumon : Fumet de crustacés 0.4 kg perdu
r = user.recipes.find_by("name ILIKE ?", "Sauce feuilleté saumon")
fumet_crustace = user.products.where("name ILIKE ?", "%crustac%").first
fix_qty!(r, fumet_crustace, 0.4, "Fumet de crustacés") if r && fumet_crustace

# Sauce ris de veau louche : crème épaisse 2L perdue
r = user.recipes.find_by("name ILIKE ?", "Sauce ris de veau louche")
fix_qty!(r, creme, 2, "Crème") if r && creme

# Sauce bolognaise : Eau 15L perdue
r = user.recipes.find_by("name ILIKE ?", "Sauce bolognaise")
eau = user.products.where("name ILIKE ?", "Eau").first
fix_qty!(r, eau, 15, "Eau") if r && eau

# Pate à croissant : Margarine 24 kg perdue (beurre plaque)
r = user.recipes.find_by("name ILIKE ?", "Pate à croissant")
margarine = user.products.where("name ILIKE ?", "%margarine%").first
fix_qty!(r, margarine, 24, "Margarine") if r && margarine

# Sauce Feuilleté ris de veau : Sel 0.95 kg perdu
r = user.recipes.find_by("name ILIKE ?", "Sauce Feuilleté ris de veau")
sel = user.products.where("name ILIKE ?", "%sel%").first
fix_qty!(r, sel, 0.95, "Sel") if r && sel

# Sauce Feuilleté poulet : Sel 0.95 kg perdu
r = user.recipes.find_by("name ILIKE ?", "Sauce Feuilleté poulet")
fix_qty!(r, sel, 0.95, "Sel") if r && sel

# ============================================================
# 4. Recalcul
# ============================================================
puts "\n=== Recalcul des recettes corrigées ==="
[
  "Sauce quiche", "Sauce feuilleté saumon", "Sauce ris de veau louche",
  "Sauce bolognaise", "Pate à croissant",
  "Sauce Feuilleté ris de veau", "Sauce Feuilleté poulet",
  "Roux", "Sauce pizza", "Gratin dauphinois", "Purée",
  "Beurre escargot", "Sauce Saint Jacques", "Sauce spaghetti",
  "Pâte à pompe", "Pate sucree", "Pâte à pâté en croûte",
  "Pâte à pâté en croûte **", "Frangipane", "Brioche aux grattons",
  "Sauce Feuilleté poulet", "Sauce Feuilleté ris de veau"
].uniq.each do |name|
  r = user.recipes.find_by("name ILIKE ?", name)
  next unless r
  Recipes::Recalculator.call(r)
  puts "  ✓ #{r.name}"
rescue => e
  puts "  WARN #{name}: #{e.message}"
end

puts "\n=== TERMINÉ ==="
