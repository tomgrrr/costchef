# encoding: utf-8
# Script de diagnostic - liste toutes les recettes/sous-recettes liées aux feuilletés
# A EXECUTER EN PREMIER pour vérifier avant suppression

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")
abort "User not found" unless user

FEUILLETE_KEYWORDS = %w[
  feuilleté feuillette feuillete
  sauce\ feuilleté béchamel\ feuilleté bechamel\ feuilleté
].freeze

def matches_feuillete?(name)
  normalized = name.downcase
    .gsub('é', 'e').gsub('è', 'e').gsub('ê', 'e')
    .gsub('à', 'a').gsub('â', 'a')
    .gsub('î', 'i').gsub('ô', 'o').gsub('û', 'u')
    .gsub('ç', 'c')
  normalized.include?('feuillet')
end

recettes   = user.recipes.where(sellable_as_component: false).order(:name).select { |r| matches_feuillete?(r.name) }
srecettes  = user.recipes.where(sellable_as_component: true).order(:name).select  { |r| matches_feuillete?(r.name) }

puts "=" * 60
puts "RECETTES (feuilletés) — #{recettes.size} trouvée(s)"
puts "=" * 60
recettes.each do |r|
  rc_count = r.recipe_components.count
  puts "  ID #{r.id}\t#{r.name}\t(#{rc_count} composants)"
end

puts ""
puts "=" * 60
puts "SOUS-RECETTES (sauces feuilletés) — #{srecettes.size} trouvée(s)"
puts "=" * 60
srecettes.each do |r|
  rc_count = r.recipe_components.count
  used_in  = RecipeComponent.where(component_type: "Recipe", component_id: r.id).count
  puts "  ID #{r.id}\t#{r.name}\t(#{rc_count} composants, utilisée dans #{used_in} recette(s))"
end

puts ""
puts "TOTAL A SUPPRIMER : #{recettes.size + srecettes.size} recette(s)"
puts ""
puts "=> Pour supprimer, lance : bin/rails runner lib/scripts/delete_feuilletes.rb"
