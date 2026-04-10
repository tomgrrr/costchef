# encoding: utf-8
# ============================================================
# CLEANUP DOUBLONS — Phase 2
# Fusions produits : oeufs frais + oeuf solide → "Oeufs frais solide"
# ============================================================

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

puts "=" * 60
puts "CLEANUP DOUBLONS 2 — compte : #{user.email}"
puts "=" * 60

# ── Helpers ──────────────────────────────────────────────────

def migrate_and_delete_product(old_product, new_product)
  puts "\n  Migration : [#{old_product.name}] (ID #{old_product.id}) → [#{new_product.name}] (ID #{new_product.id})"
  count = old_product.recipe_components.count
  puts "  → #{count} composant(s) à migrer"

  old_product.recipe_components.each do |rc|
    recipe_name = rc.parent_recipe&.name || "?"
    existing = RecipeComponent.find_by(parent_recipe_id: rc.parent_recipe_id, component_type: "Product", component_id: new_product.id)
    if existing
      new_qty = existing.quantity_kg + rc.quantity_kg
      existing.update!(quantity_kg: new_qty)
      rc.destroy!
      puts "    ✓ #{recipe_name} : quantités fusionnées → #{new_qty.round(4)} kg"
    else
      rc.update!(component_id: new_product.id)
      puts "    ✓ #{recipe_name} : rebranchée"
    end
  end

  old_product.reload
  if old_product.recipe_components.count > 0
    puts "  ❌ ABORT suppression — encore #{old_product.recipe_components.count} composant(s) liés !"
    return false
  end

  old_product.destroy!
  puts "  ✅ Supprimé : #{old_product.name} (ID #{old_product.id})"
  true
rescue => e
  puts "  ❌ Erreur : #{e.message}"
  false
end

# ============================================================
# FUSION : Oeuf frais + oeuf solide → "Oeufs frais solide"
# ============================================================
puts "\n── Fusion oeufs ──"

oeuf_a = user.products.where("name ILIKE ?", "%oeuf frais%").first
oeuf_b = user.products.where("name ILIKE ?", "%oeuf solide%").first

if oeuf_a.nil? && oeuf_b.nil?
  puts "  ❌ Aucun des deux produits trouvé — vérifier les noms en base"
elsif oeuf_a.nil?
  puts "  ⚠️  'Oeuf frais' introuvable — renommage de 'oeuf solide' seul"
  oeuf_b.update!(name: "Oeufs frais solide")
  puts "  ✅ Renommé : #{oeuf_b.name} (ID #{oeuf_b.id})"
elsif oeuf_b.nil?
  puts "  ⚠️  'Oeuf solide' introuvable — renommage de 'Oeuf frais' seul"
  oeuf_a.update!(name: "Oeufs frais solide")
  puts "  ✅ Renommé : #{oeuf_a.name} (ID #{oeuf_a.id})"
else
  puts "  Trouvé A : #{oeuf_a.name} (ID #{oeuf_a.id}) — #{oeuf_a.recipe_components.count} recette(s)"
  puts "  Trouvé B : #{oeuf_b.name} (ID #{oeuf_b.id}) — #{oeuf_b.recipe_components.count} recette(s)"

  # Garder celui avec le plus de recettes liées (probablement oeuf_a)
  keeper  = oeuf_a.recipe_components.count >= oeuf_b.recipe_components.count ? oeuf_a : oeuf_b
  dropper = keeper == oeuf_a ? oeuf_b : oeuf_a

  puts "  → On garde : #{keeper.name} (ID #{keeper.id}), on migre : #{dropper.name} (ID #{dropper.id})"

  migrate_and_delete_product(dropper, keeper)

  keeper.reload
  keeper.update!(name: "Oeufs frais solide")
  puts "  ✅ Renommé → 'Oeufs frais solide' (ID #{keeper.id})"
end

puts "\n" + "=" * 60
puts "✅ Cleanup 2 terminé"
puts "=" * 60
