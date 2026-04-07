# encoding: utf-8
# frozen_string_literal: true
# Re-lie les composants recettes de "Ail" (ID 900, 0 condits) → "Ail haché surgelé"
# Même chose pour les autres produits splittés qui ont des recettes orphelines :
#   Carotte → Carotte entière
#   Échalote → Échalote hachée surgelée
#   Oignons → Oignons émincés
#   Poireaux → Poireaux coupés
#   Saumon → TR saumon fumé

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

def relink_recettes(user, src_name, dst_name)
  src = user.products.find_by("name ILIKE ?", src_name)
  unless src
    puts "  ⚠️  Source '#{src_name}' introuvable"
    return
  end

  dst = user.products.find_by("name = ?", dst_name) ||
        user.products.find_by("name ILIKE ?", dst_name)
  unless dst
    puts "  ⚠️  Cible '#{dst_name}' introuvable"
    return
  end

  rcs = RecipeComponent.where(component_type: "Product", component_id: src.id)
  if rcs.empty?
    puts "  ℹ️  '#{src.name}' — aucun composant recette à relinkier"
    return
  end

  rcs.each do |rc|
    # Vérifier si la recette a déjà le produit cible (contrainte unicité)
    exists = RecipeComponent.exists?(
      parent_recipe_id: rc.parent_recipe_id,
      component_type: "Product",
      component_id: dst.id
    )
    if exists
      recette = rc.parent_recipe
      puts "  ⚠️  #{recette.name} a déjà '#{dst.name}' — fusion des quantités"
      existing = RecipeComponent.find_by(parent_recipe_id: rc.parent_recipe_id, component_type: "Product", component_id: dst.id)
      existing.update!(quantity_kg: existing.quantity_kg + rc.quantity_kg)
      rc.destroy!
    else
      rc.update!(component_id: dst.id)
    end
  end

  puts "  ✅ '#{src.name}' (ID #{src.id}) → '#{dst.name}' (ID #{dst.id}) : #{rcs.size} recette(s) relinkées"

  # Recalcul des recettes impactées
  recette_ids = rcs.map(&:parent_recipe_id).uniq
  recette_ids.each do |rid|
    r = Recipe.find_by(id: rid)
    next unless r
    Recipes::Recalculator.call(r)
    r.reload
    puts "     → #{r.name} recalculé : #{r.cached_cost_per_kg.to_f.round(2)} €/kg"
  end
end

puts "=== RELINK RECETTES PRODUITS SPLITTÉS ==="

puts "\n1. Ail → Ail haché surgelé"
relink_recettes(user, "Ail", "Ail haché surgelé")

puts "\n2. Carotte → Carotte entière"
relink_recettes(user, "Carotte", "Carotte entière")

puts "\n3. Echalote → Échalote hachée surgelée"
relink_recettes(user, "Echalote", "Échalote hachée surgelée")

puts "\n4. Oignons → Oignons émincés"
relink_recettes(user, "Oignons", "Oignons émincés")

puts "\n5. Poireaux → Poireaux coupés"
relink_recettes(user, "Poireaux", "Poireaux coupés")

puts "\n6. Saumon → TR saumon fumé"
relink_recettes(user, "Saumon", "TR saumon fumé")

puts "\n=== TERMINÉ ==="
