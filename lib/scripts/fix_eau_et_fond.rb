# encoding: utf-8
# frozen_string_literal: true
# 1. Bolognaise : Fond de volaille → Fond de veau (produits différents)
# 2. Ajout Eau manquante dans 5 recettes : Jus de fruit, Purée,
#    Vinaigrette, Vinaigrette balsamique, Vinaigrette carottes rapées
# 3. Suppression produit fantôme "Macardan" si présent

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

eau = user.products.find_by!("LOWER(name) = ?", "eau")

ActiveRecord::Base.transaction do

  # ── 1. BOLOGNAISE : Fond de volaille → Fond de veau ──────────────────
  puts "=== Bolognaise : Fond de volaille → Fond de veau ==="
  bolo = user.recipes.find_by!("LOWER(name) LIKE ?", "%bolognaise%")

  fond_volaille = user.products.find_by("name ILIKE ?", "%volaille%")
  fond_veau     = user.products.find_by("name ILIKE ?", "%fond%veau%")
  fond_veau   ||= user.products.find_by("name ILIKE ?", "%veau%fond%")

  raise "Fond de volaille introuvable en base" unless fond_volaille
  raise "Fond de veau introuvable en base"     unless fond_veau

  puts "  Fond de volaille : #{fond_volaille.name} (ID #{fond_volaille.id})"
  puts "  Fond de veau     : #{fond_veau.name} (ID #{fond_veau.id})"

  rc = bolo.recipe_components.find_by(component_type: "Product", component_id: fond_volaille.id)
  if rc
    rc.update!(component_id: fond_veau.id)
    puts "  [FIX] #{fond_volaille.name} → #{fond_veau.name} (#{rc.quantity_kg} kg)"
  else
    puts "  [OK] Fond de volaille absent de Bolognaise — vérifier manuellement"
  end

  Recipes::Recalculator.call(bolo)
  bolo.reload
  puts "  → #{bolo.cached_cost_per_kg.round(2)} EUR/kg"

  # ── 2. EAU MANQUANTE ─────────────────────────────────────────────────
  a_corriger = [
    { name: "Jus de fruit",              qty: 3.0  },
    { name: "Purée",                     qty: 1.5  },
    { name: "Vinaigrette",               qty: 4.0  },
    { name: "Vinaigrette balsamique",    qty: 4.0  },
    { name: "Vinaigrette carottes rapées", qty: 4.0 },
  ]

  puts "\n=== Ajout Eau manquante ==="
  a_corriger.each do |entry|
    r = user.recipes.find_by("LOWER(name) LIKE ?", "%#{entry[:name].downcase}%")
    unless r
      puts "  [INTROUVABLE] #{entry[:name]}"
      next
    end

    existant = r.recipe_components.find_by(component_type: "Product", component_id: eau.id)
    if existant
      puts "  [OK] #{r.name} — Eau déjà présente (#{existant.quantity_kg} kg)"
    else
      r.recipe_components.create!(component: eau, quantity_kg: entry[:qty], quantity_unit: "kg")
      Recipes::Recalculator.call(r)
      r.reload
      puts "  [AJOUT] #{r.name} — Eau #{entry[:qty]} kg → #{r.cached_cost_per_kg.round(2)} EUR/kg | #{r.cached_total_weight.round(2)} kg total"
    end
  end

  # ── 3. SUPPRESSION FANTÔME "Macardan" ────────────────────────────────
  puts "\n=== Produit fantôme Macardan ==="
  macardan = user.products.find_by("LOWER(name) = ?", "macardan")
  if macardan
    n = RecipeComponent.where(component_type: "Product", component_id: macardan.id).count
    if n == 0
      macardan.destroy!
      puts "  [SUPPRIME] Macardan (0 recette liée)"
    else
      puts "  [ATTENTION] Macardan lié à #{n} recette(s) — non supprimé"
    end
  else
    puts "  [OK] Pas de produit Macardan en base"
  end

end
