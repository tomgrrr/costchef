# encoding: utf-8
# frozen_string_literal: true
# Supprime les anciennes sous-recettes sans suffixe "sous recette"
# creees par l'ancien import de masse, remplacees par les batches

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

# Noms exacts a supprimer (doublons de l'ancien import)
TO_DELETE = [
  "TPT",
  "Vinaigrette balsamique",
  "Vinaigrette",
  "Jus de fruit",
].freeze

puts "Nettoyage des doublons...\n"

ActiveRecord::Base.transaction do
  TO_DELETE.each do |name|
    r = user.recipes.find_by("name = ?", name)
    if r
      RecipeComponent.where(parent_recipe_id: r.id).delete_all
      RecipeComponent.where(component_type: "Recipe", component_id: r.id).delete_all
      r.destroy!
      puts "  [SUPPRIME] #{name}"
    else
      puts "  [ABSENT]   #{name} (rien a faire)"
    end
  end
end

puts "\nSous-recettes restantes : #{user.recipes.where(sellable_as_component: true).count}"
user.recipes.where(sellable_as_component: true).order(:name).pluck(:name).each { |n| puts "  - #{n}" }
