# encoding: utf-8
# ============================================================
# CLEANUP DOUBLONS — Phase 1
# Fusionne les produits en doublon, supprime les recettes en double
# ============================================================

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

puts "=" * 60
puts "CLEANUP DOUBLONS — compte : #{user.email}"
puts "=" * 60

errors = []

# ── Helpers ──────────────────────────────────────────────────

def safe_delete_product(product, label)
  count = product.recipe_components.count
  if count > 0
    puts "  ❌ ABORT — #{label} (ID #{product.id}) encore utilisé dans #{count} composant(s) !"
    return false
  end
  product.destroy!
  puts "  ✅ Produit supprimé : #{label} (ID #{product.id})"
  true
rescue => e
  puts "  ❌ Erreur suppression #{label} : #{e.message}"
  false
end

def migrate_and_delete_product(old_product, new_product, old_label, new_label)
  count = old_product.recipe_components.count
  puts "  → Migration #{count} composant(s) de [#{old_label}] vers [#{new_label}]"
  old_product.recipe_components.each do |rc|
    recipe_name = rc.parent_recipe&.name || "?"
    existing = rc.parent_recipe&.recipe_components&.find_by(component_type: "Product", component_id: new_product.id)
    if existing
      # Fusionner les quantités
      existing.update!(quantity_kg: existing.quantity_kg + rc.quantity_kg)
      rc.destroy!
      puts "    ✓ #{recipe_name} : quantités fusionnées (#{rc.quantity_kg} + #{existing.quantity_kg - rc.quantity_kg} kg)"
    else
      rc.update!(component_id: new_product.id)
      puts "    ✓ #{recipe_name} : rebranchée sur #{new_label}"
    end
  end
  old_product.reload
  safe_delete_product(old_product, old_label)
rescue => e
  puts "  ❌ Erreur migration #{old_label} : #{e.message}"
  false
end

def safe_delete_recipe(recipe, label)
  # Vérifier qu'elle n'est pas utilisée comme composant dans une autre recette
  usage = RecipeComponent.where(component_type: "Recipe", component_id: recipe.id).count
  if usage > 0
    puts "  ❌ ABORT — #{label} (ID #{recipe.id}) est composant dans #{usage} recette(s) !"
    return false
  end
  recipe.recipe_components.destroy_all
  recipe.destroy!
  puts "  ✅ Recette supprimée : #{label} (ID #{recipe.id})"
  true
rescue => e
  puts "  ❌ Erreur suppression recette #{label} : #{e.message}"
  false
end

# ============================================================
# ÉTAPE 1 — VÉRIFICATIONS (lecture seule)
# ============================================================
puts "\n── Étape 1 : Vérifications ──"

p_chair_saucisse = user.products.find_by(id: 1236)
p_poudre_puree   = user.products.find_by(id: 1205)
p_jus_champ_old  = user.products.find_by(id: 1237)
p_jus_champ_new  = user.products.find_by(id: 1198)
p_echalote_old   = user.products.find_by(id: 913)
p_echalote_new   = user.products.find_by(id: 1142)

r_beurre_bad     = user.recipes.find_by(id: 193)   # Beurre escargot  → supprimer
r_poireaux_bad   = user.recipes.find_by(id: 164)   # Poireaux+espace  → supprimer
r_fricassee_bad  = user.recipes.find_by(id: 272)   # Fricassée (neuf) → supprimer

[
  [p_chair_saucisse, "chair saucisse (1236)"],
  [p_poudre_puree,   "poudre puree (1205)"],
  [p_jus_champ_old,  "jus champignon (1237)"],
  [p_jus_champ_new,  "Jus de champignon (1198)"],
  [p_echalote_old,   "Echalote sans accent (913)"],
  [p_echalote_new,   "Échalote avec accent (1142)"],
  [r_beurre_bad,     "Beurre escargot recette (193)"],
  [r_poireaux_bad,   "Poireaux+espace recette (164)"],
  [r_fricassee_bad,  "Fricassée de volaille (272)"],
].each do |obj, label|
  if obj.nil?
    puts "  ⚠️  INTROUVABLE : #{label} — peut-être déjà supprimé ?"
  else
    puts "  ✓ Trouvé : #{label} — #{obj.class.name}"
  end
end

# ============================================================
# ÉTAPE 2 — MIGRATIONS PRODUITS
# ============================================================
puts "\n── Étape 2 : Migrations produits ──"

if p_jus_champ_old && p_jus_champ_new
  migrate_and_delete_product(p_jus_champ_old, p_jus_champ_new, "jus champignon", "Jus de champignon")
else
  puts "  ⚠️  Skip migration jus champignon (produit introuvable)"
end

if p_echalote_old && p_echalote_new
  migrate_and_delete_product(p_echalote_old, p_echalote_new, "Echalote", "Échalote")
else
  puts "  ⚠️  Skip migration échalote (produit introuvable)"
end

# ============================================================
# ÉTAPE 3 — SUPPRESSIONS PRODUITS ORPHELINS
# ============================================================
puts "\n── Étape 3 : Suppressions produits orphelins ──"

safe_delete_product(p_chair_saucisse, "chair saucisse") if p_chair_saucisse
safe_delete_product(p_poudre_puree,   "poudre puree")   if p_poudre_puree

# ============================================================
# ÉTAPE 4 — SUPPRESSIONS RECETTES EN DOUBLON
# ============================================================
puts "\n── Étape 4 : Suppressions recettes en doublon ──"

safe_delete_recipe(r_beurre_bad,    "Beurre escargot")       if r_beurre_bad
safe_delete_recipe(r_poireaux_bad,  "Poireaux (avec espace)") if r_poireaux_bad
safe_delete_recipe(r_fricassee_bad, "Fricassée de volaille")  if r_fricassee_bad

# ============================================================
# RÉSUMÉ
# ============================================================
puts "\n" + "=" * 60
puts "✅ Cleanup terminé"
puts "=" * 60
