# encoding: utf-8
# frozen_string_literal: true
# Fusionne les doublons produits détectés par audit_products :
#   - Fecule → Fécule (accent)
#   - Égrainés de boeuf → Égrainés de bœuf (ligature oe/œ)
#   - Crème épaisse → Crème (même produit, confirmé par Dimitry)

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

def fusionner!(user, garder_name, supprimer_pattern)
  garder    = user.products.find_by!("name = ?", garder_name)
  supprimer = user.products.find_by("name ILIKE ?", supprimer_pattern)

  unless supprimer
    puts "  [OK] Doublon '#{supprimer_pattern}' absent — rien à faire"
    return
  end

  if garder.id == supprimer.id
    puts "  [OK] Même produit, rien à faire"
    return
  end

  puts "  Garder    : #{garder.name} (ID #{garder.id}) — #{garder.avg_price_per_kg.to_f.round(2)} €/kg | #{garder.product_purchases.count} condits"
  puts "  Supprimer : #{supprimer.name} (ID #{supprimer.id}) — #{supprimer.avg_price_per_kg.to_f.round(2)} €/kg | #{supprimer.product_purchases.count} condits"

  n = RecipeComponent.where(component_type: "Product", component_id: supprimer.id).count
  RecipeComponent.where(component_type: "Product", component_id: supprimer.id)
                 .update_all(component_id: garder.id)
  puts "  [FIX] #{n} RecipeComponent(s) rerattaché(s) vers #{garder.name}"

  supprimer.product_purchases.delete_all
  supprimer.destroy!
  puts "  [SUPPRIME] #{supprimer.name}"
end

ActiveRecord::Base.transaction do

  # ── Fecule / Fécule ──────────────────────────────────────────────────
  puts "=== Fecule / Fécule ==="
  # Garder celui qui a des conditionnements ou le mieux nommé
  fecule_accent = user.products.find_by("name = ?", "Fécule")
  fecule_sans   = user.products.find_by("name = ?", "Fecule")

  if fecule_accent && fecule_sans
    # Garder Fécule (avec accent), fusionner Fecule dedans
    fusionner!(user, "Fécule", "Fecule")
  elsif fecule_sans && !fecule_accent
    fecule_sans.update!(name: "Fécule")
    puts "  [RENOMME] Fecule → Fécule"
  else
    puts "  [OK] Pas de doublon Fecule/Fécule"
  end

  # ── Égrainés de boeuf / Égrainés de bœuf ────────────────────────────
  puts "\n=== Égrainés de boeuf / Égrainés de bœuf ==="
  # Garder celui qui est utilisé dans les recettes (Egrene = le vrai produit avec condits)
  egrene = user.products.find_by("name ILIKE ?", "%grene%")  # "Egrene" = le produit avec prix
  egraine_boeuf = user.products.find_by("name ILIKE ? AND name NOT ILIKE ?", "%grain%boeuf%", "%grene%")
  egraine_boeuf ||= user.products.find_by("name ILIKE ? AND name NOT ILIKE ?", "%grain%b%uf%", "%grene%")

  puts "  Produit référence (Egrene) : #{egrene&.name} (ID #{egrene&.id})"
  puts "  Doublon trouvé : #{egraine_boeuf&.name} (ID #{egraine_boeuf&.id})"

  if egraine_boeuf && egraine_boeuf.id != egrene&.id
    n = RecipeComponent.where(component_type: "Product", component_id: egraine_boeuf.id).count
    RecipeComponent.where(component_type: "Product", component_id: egraine_boeuf.id)
                   .update_all(component_id: egrene.id)
    egraine_boeuf.product_purchases.delete_all
    egraine_boeuf.destroy!
    puts "  [FIX] #{n} composant(s) rerattaché(s) vers #{egrene.name}"
    puts "  [SUPPRIME] #{egraine_boeuf.name}"
  else
    puts "  [OK] Pas de doublon actif"
  end

  # Recalculer Bolognaise
  bolo = user.recipes.find_by("LOWER(name) LIKE ?", "%bolognaise%")
  if bolo
    Recipes::Recalculator.call(bolo)
    bolo.reload
    puts "\n  [RECALCUL] #{bolo.name} → #{bolo.cached_cost_per_kg.round(2)} EUR/kg"
  end

  # ── Crème épaisse → Crème ────────────────────────────────────────────
  # Contrainte unicité (parent_recipe_id, component_type, component_id) :
  # si la recette a déjà Crème ET Crème épaisse, on fusionne les quantités
  # plutôt que de faire un update_all qui violerait la contrainte.
  puts "\n=== Crème épaisse → Crème ==="
  creme = user.products.find_by!("LOWER(name) = ?", "crème")

  creme_epaisse = user.products.find_by("LOWER(name) = ?", "crème épaisse")
  unless creme_epaisse
    puts "  [OK] Crème épaisse absente — rien à faire"
  else
    puts "  Garder    : #{creme.name} (ID #{creme.id}) — #{creme.avg_price_per_kg.to_f.round(2)} €/kg"
    puts "  Supprimer : #{creme_epaisse.name} (ID #{creme_epaisse.id})"

    rcs_epaisse = RecipeComponent.where(component_type: "Product", component_id: creme_epaisse.id)
    puts "  #{rcs_epaisse.count} recette(s) concernée(s)"

    recettes_impactees = []

    rcs_epaisse.each do |rc_ep|
      recette = rc_ep.parent_recipe
      rc_creme = RecipeComponent.find_by(
        parent_recipe_id: recette.id,
        component_type: "Product",
        component_id: creme.id
      )

      if rc_creme
        # La recette a déjà Crème → additionner les quantités et supprimer Crème épaisse
        nouvelle_qte = rc_creme.quantity_kg + rc_ep.quantity_kg
        rc_ep.destroy!
        rc_creme.update!(quantity_kg: nouvelle_qte)
        puts "    [FUSION] #{recette.name} : Crème #{rc_creme.quantity_kg - rc_ep.quantity_kg rescue nouvelle_qte}kg + #{rc_ep.quantity_kg}kg → #{nouvelle_qte}kg"
      else
        # Pas de Crème dans cette recette → simple rerattachement
        rc_ep.update!(component_id: creme.id)
        puts "    [RERATTACHE] #{recette.name} : Crème épaisse → Crème (#{rc_ep.quantity_kg}kg)"
      end

      recettes_impactees << recette
    end

    creme_epaisse.product_purchases.delete_all
    creme_epaisse.destroy!
    puts "  [SUPPRIME] Crème épaisse"

    puts "  Recalcul #{recettes_impactees.count} recette(s) :"
    recettes_impactees.uniq.each do |r|
      Recipes::Recalculator.call(r)
      r.reload
      puts "    #{r.name} → #{r.cached_cost_per_kg.round(2)} EUR/kg"
    end
  end

end
