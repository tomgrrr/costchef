# encoding: utf-8
# Script de suppression - supprime toutes les recettes/sous-recettes feuilletés
# EXECUTER SEULEMENT après avoir vérifié la liste avec list_feuilletes.rb

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")
abort "User not found" unless user

def matches_feuillete?(name)
  normalized = name.downcase
    .gsub('é', 'e').gsub('è', 'e').gsub('ê', 'e')
    .gsub('à', 'a').gsub('â', 'a')
    .gsub('î', 'i').gsub('ô', 'o').gsub('û', 'u')
    .gsub('ç', 'c')
  normalized.include?('feuillet')
end

all = user.recipes.order(:name).select { |r| matches_feuillete?(r.name) }

puts "#{all.size} recette(s) à supprimer :"
all.each { |r| puts "  - [#{r.sellable_as_component? ? 'SR' : 'R '}] #{r.id}\t#{r.name}" }
puts ""

# Supprimer d'abord les recettes parentes (non sous-recettes),
# puis les sous-recettes (pour éviter les contraintes de RC)
recettes  = all.select { |r| !r.sellable_as_component? }
srecettes = all.select { |r|  r.sellable_as_component? }

recettes.each do |r|
  r.recipe_components.destroy_all
  r.destroy!
  puts "SUPPRIMÉ [R ] #{r.id} — #{r.name}"
end

srecettes.each do |r|
  r.recipe_components.destroy_all
  r.destroy!
  puts "SUPPRIMÉ [SR] #{r.id} — #{r.name}"
end

puts ""
puts "DONE — #{all.size} recette(s) supprimée(s)"
