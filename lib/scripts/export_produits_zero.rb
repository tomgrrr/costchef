# encoding: utf-8
# frozen_string_literal: true
#
# Export JSON des produits "à 0" du compte Lassalas :
#   - sans_prix        : avg_price_per_kg == 0 (produit présent, pas de prix valide)
#   - sans_condits     : aucun product_purchase rattaché
#
# Usage (Render shell) :
#   bundle exec rails runner lib/scripts/export_produits_zero.rb
#
# La sortie JSON est encadrée par des marqueurs BEGIN_JSON / END_JSON
# pour faciliter la copie depuis les logs Render.

require 'json'

EMAIL = 'dp.lassalas@outlook.fr'

user = User.find_by!('email ILIKE ?', EMAIL)

products = user.products
               .includes(:product_purchases, recipe_components: :parent_recipe)
               .order(:name)

def serialize(product)
  recipes = product.recipe_components
                   .map { |rc| rc.parent_recipe&.name }
                   .compact
                   .uniq
                   .sort

  {
    id: product.id,
    name: product.name,
    base_unit: product.base_unit,
    avg_price_per_kg: product.avg_price_per_kg.to_f.round(4),
    purchase_count: product.product_purchases.size,
    used_in_recipes_count: recipes.size,
    used_in_recipes: recipes,
    dehydrated: product.dehydrated
  }
end

sans_prix    = products.select { |p| p.avg_price_per_kg.to_f == 0.0 }
sans_condits = products.select { |p| p.product_purchases.empty? }

# Un produit sans conditionnement a forcément un prix à 0 → on soustrait l'overlap
# pour la catégorie "sans_prix" (ceux qui ont >=1 condit mais dont le prix reste 0)
sans_prix_only = sans_prix.reject { |p| p.product_purchases.empty? }

payload = {
  generated_at: Time.now.utc.iso8601,
  user_email: user.email,
  total_products: products.size,
  counts: {
    sans_prix_total: sans_prix.size,
    sans_prix_avec_condit: sans_prix_only.size,
    sans_conditionnement: sans_condits.size
  },
  sans_prix_avec_condit: sans_prix_only.map { |p| serialize(p) },
  sans_conditionnement: sans_condits.map { |p| serialize(p) }
}

puts
puts '===BEGIN_JSON==='
puts JSON.pretty_generate(payload)
puts '===END_JSON==='
puts

# Résumé lisible en plus du JSON
puts '─' * 60
puts "Compte          : #{user.email}"
puts "Produits total  : #{products.size}"
puts "Sans prix (0€)  : #{sans_prix.size}  (dont #{sans_prix_only.size} avec au moins 1 conditionnement)"
puts "Sans condit     : #{sans_condits.size}"
puts '─' * 60
