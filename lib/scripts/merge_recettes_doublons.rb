# encoding: utf-8

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")

def merge_recipes(keeper, old)
  puts "  Keeper : ID #{keeper.id} — #{keeper.name}"
  puts "  Ancien : ID #{old.id} — #{old.name}"

  # Migrer les recipe_components qui utilisent "old" comme sous-recette
  rc_list = RecipeComponent.where(component_type: "Recipe", component_id: old.id)
  puts "  #{rc_list.count} recipe_component(s) à migrer"
  rc_list.each do |rc|
    existing = RecipeComponent.find_by(parent_recipe_id: rc.parent_recipe_id, component_type: "Recipe", component_id: keeper.id)
    if existing
      rc.destroy!
      puts "    Doublon RC supprimé (recette #{rc.parent_recipe_id})"
    else
      rc.update!(component_id: keeper.id)
      puts "    Rebranché → #{keeper.name} (recette #{rc.parent_recipe_id})"
    end
  end

  old.destroy!
  puts "  Supprimé : ID #{old.id} — #{old.name}"
rescue => e
  puts "  ERREUR suppression : #{e.message} — tentative .delete"
  old.delete
  puts "  Supprimé via .delete"
end

# ============================================================
# 1. Pate sucree → Pâte sucrée
# ============================================================
puts "=== Pate sucree → Pâte sucrée ==="
keeper = user.recipes.where("name = ?", "Pâte sucrée").first
old    = user.recipes.where("name ILIKE ?", "pate sucree").where.not(id: keeper&.id).first
if old && keeper
  merge_recipes(keeper, old)
else
  puts "  Introuvable — skip"
end

# ============================================================
# 2. Sauce St Jacques → Sauce Saint Jacques
# ============================================================
puts ""
puts "=== Sauce St Jacques → Sauce Saint Jacques ==="
keeper = user.recipes.where("name ILIKE ?", "sauce saint jacques").first
old    = user.recipes.where("name ILIKE ?", "sauce st jacques").where.not(id: keeper&.id).first
if old && keeper
  merge_recipes(keeper, old)
else
  puts "  Introuvable — skip"
end

# ============================================================
# 3. TPT → Tant pour tant (T.P.T.)
# ============================================================
puts ""
puts "=== TPT → Tant pour tant (T.P.T.) ==="
keeper = user.recipes.where("name ILIKE ?", "tant pour tant%").first
old    = user.recipes.where("name ILIKE ?", "tpt").where.not(id: keeper&.id).first
if old && keeper
  merge_recipes(keeper, old)
else
  puts "  Introuvable — skip"
end

# ============================================================
# 4. Pâté pommes de terre — supprimer les variantes 2/4 portions
# ============================================================
puts ""
puts "=== Pâté pommes de terre — suppression variantes ==="
keeper = user.recipes.where("name ILIKE ?", "pâté pommes de terre").first ||
         user.recipes.where("name ILIKE ?", "paté pomme de terre").where.not("name ILIKE ?", "% portions").first
variants = user.recipes.where("name ILIKE ?", "paté pomme de terre % portions")

puts "  Keeper : ID #{keeper&.id} — #{keeper&.name}"
variants.each do |old|
  next if old.id == keeper&.id
  merge_recipes(keeper, old)
  puts ""
end

puts ""
puts "Recalcul des recettes impactées..."
user.recipes.each do |r|
  Recipes::Recalculator.call(r)
rescue => e
  # skip
end

puts "Done."
