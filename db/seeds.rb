# frozen_string_literal: true

# =============================================================================
# Seeds CostChef — Données complètes de démonstration
# =============================================================================
# Exécution : bin/rails db:seed
# Reset complet : bin/rails db:drop db:create db:migrate db:seed
# =============================================================================

puts '=' * 60
puts 'CostChef — Création des données de démonstration'
puts '=' * 60

# =============================================================================
# 1. UTILISATEURS
# =============================================================================
puts "\n1. Création des utilisateurs..."

admin = User.find_or_initialize_by(email: 'admin@costchef.fr')
admin.assign_attributes(
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Admin',
  last_name: 'CostChef',
  company_name: 'CostChef SAS',
  subscription_active: true,
  subscription_started_at: Date.today,
  subscription_expires_at: 1.year.from_now,
  admin: true
)
admin.save!
puts '   admin@costchef.fr (admin, abonnement actif)'

christophe = User.find_or_initialize_by(email: 'christophe@traiteur.fr')
christophe.assign_attributes(
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Christophe',
  last_name: 'Dupont',
  company_name: 'Traiteur Dupont',
  subscription_active: true,
  subscription_started_at: Date.today,
  subscription_expires_at: 1.year.from_now,
  admin: false
)
christophe.save!
puts '   christophe@traiteur.fr (abonnement actif)'

laurent = User.find_or_initialize_by(email: 'laurent@nouveau.fr')
laurent.assign_attributes(
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Laurent',
  last_name: 'Martin',
  company_name: 'Nouveau Traiteur',
  subscription_active: false,
  subscription_started_at: nil,
  subscription_expires_at: nil,
  admin: false
)
laurent.save!
puts '   laurent@nouveau.fr (sans abonnement — test gating)'

# =============================================================================
# 2. FOURNISSEURS (pour Christophe)
# =============================================================================
puts "\n2. Création des fournisseurs..."

suppliers_data = [
  { name: 'Pomona' },
  { name: 'Brake France' },
  { name: 'Transgourmet' },
  { name: 'Metro' }
]

suppliers = {}
suppliers_data.each do |data|
  supplier = christophe.suppliers.find_or_initialize_by(name: data[:name])
  supplier.save!
  suppliers[data[:name]] = supplier
  puts "   #{data[:name]}"
end

# =============================================================================
# 3. PRODUITS (pour Christophe)
# =============================================================================
puts "\n3. Création des produits..."

products_data = [
  { name: 'Poulet entier',   base_unit: 'piece', unit_weight_kg: 1.5 },
  { name: 'Filet de saumon', base_unit: 'kg' },
  { name: 'Carottes',        base_unit: 'kg' },
  { name: 'Pommes de terre', base_unit: 'kg' },
  { name: 'Oignons',         base_unit: 'kg' },
  { name: 'Crème fraîche',   base_unit: 'l' },
  { name: 'Beurre',          base_unit: 'kg' },
  { name: 'Huile d\'olive',  base_unit: 'l' },
  { name: 'Sel fin',         base_unit: 'kg' },
  { name: 'Poivre noir',     base_unit: 'kg' },
  { name: 'Farine T55',      base_unit: 'kg' },
  { name: 'Oeuf',            base_unit: 'piece', unit_weight_kg: 0.06 }
]

products = {}
products_data.each do |data|
  product = christophe.products.find_or_initialize_by(name: data[:name])
  product.assign_attributes(
    base_unit: data[:base_unit],
    unit_weight_kg: data[:unit_weight_kg]
  )
  product.save!
  products[data[:name]] = product
  puts "   #{data[:name]} (#{data[:base_unit]})"
end

# =============================================================================
# 4. ACHATS FOURNISSEURS + CALCULS (pour Christophe)
# =============================================================================
puts "\n4. Création des achats et calcul des prix..."

purchases_data = [
  { product: 'Poulet entier',   supplier: 'Brake France',  qty: 1,    unit: 'piece', price: 7.50 },
  { product: 'Filet de saumon', supplier: 'Brake France',  qty: 1,    unit: 'kg',    price: 22.00 },
  { product: 'Carottes',        supplier: 'Pomona',        qty: 5,    unit: 'kg',    price: 4.50 },
  { product: 'Pommes de terre', supplier: 'Pomona',        qty: 10,   unit: 'kg',    price: 8.00 },
  { product: 'Oignons',         supplier: 'Pomona',        qty: 5,    unit: 'kg',    price: 3.75 },
  { product: 'Crème fraîche',   supplier: 'Transgourmet',  qty: 1,    unit: 'l',     price: 4.20 },
  { product: 'Beurre',          supplier: 'Transgourmet',  qty: 500,  unit: 'g',     price: 4.50 },
  { product: 'Huile d\'olive',  supplier: 'Metro',         qty: 1,    unit: 'l',     price: 8.90 },
  { product: 'Sel fin',         supplier: 'Metro',         qty: 1,    unit: 'kg',    price: 0.85 },
  { product: 'Poivre noir',     supplier: 'Metro',         qty: 100,  unit: 'g',     price: 5.60 },
  { product: 'Farine T55',      supplier: 'Transgourmet',  qty: 5,    unit: 'kg',    price: 3.90 },
  { product: 'Oeuf',            supplier: 'Transgourmet',  qty: 30,   unit: 'piece', price: 6.90 }
]

purchases_data.each do |data|
  product = products[data[:product]]
  supplier = suppliers[data[:supplier]]

  purchase = product.product_purchases.find_or_initialize_by(supplier: supplier)
  purchase.assign_attributes(
    package_quantity: data[:qty],
    package_unit: data[:unit],
    package_price: data[:price],
    active: true
  )

  # Calcul des champs dérivés via le service
  ProductPurchases::PricePerKgCalculator.call(purchase)
  purchase.save!

  puts "   #{data[:product]} ← #{data[:supplier]} : " \
       "#{data[:qty]} #{data[:unit]} = #{data[:price]}€ → #{purchase.price_per_kg.round(2)}€/kg"
end

# Recalcul des prix moyens de chaque produit
puts "\n   Recalcul des prix moyens..."
products.each_value do |product|
  Products::AvgPriceRecalculator.call(product)
  product.reload
  puts "   #{product.name} : #{product.avg_price_per_kg.round(2)}€/kg"
end

# =============================================================================
# 5. BARQUETTES (pour Christophe)
# =============================================================================
puts "\n5. Création des barquettes..."

tray_sizes_data = [
  { name: 'Barquette individuelle',      price: 0.50 },
  { name: 'Barquette 4 personnes',       price: 1.20 },
  { name: 'Plat traiteur 10 personnes',  price: 2.50 }
]

tray_sizes = {}
tray_sizes_data.each do |data|
  tray = christophe.tray_sizes.find_or_initialize_by(name: data[:name])
  tray.assign_attributes(price: data[:price])
  tray.save!
  tray_sizes[data[:name]] = tray
  puts "   #{data[:name]} (#{data[:price]}€)"
end

# =============================================================================
# 6. RECETTES + COMPOSANTS (pour Christophe)
# =============================================================================
puts "\n6. Création des recettes..."

# --- Purée de carottes (sous-recette) ---
puree = christophe.recipes.find_or_initialize_by(name: 'Purée de carottes')
puree.assign_attributes(
  description: 'Purée de carottes maison, onctueuse au beurre et crème fraîche.',
  cooking_loss_percentage: 15,
  sellable_as_component: true,
  has_tray: false
)
puree.save!

puree_components = [
  { component: products['Carottes'],       quantity_kg: 1.0 },
  { component: products['Beurre'],         quantity_kg: 0.1 },
  { component: products['Crème fraîche'],  quantity_kg: 0.2 },
  { component: products['Sel fin'],        quantity_kg: 0.01 }
]

puree_components.each do |data|
  comp = puree.recipe_components.find_or_initialize_by(
    component_type: 'Product',
    component_id: data[:component].id
  )
  comp.assign_attributes(quantity_kg: data[:quantity_kg])
  comp.save!
end

Recipes::Recalculator.call(puree)
puree.reload
puts "   Purée de carottes : #{puree.cached_total_cost.round(2)}€ | " \
     "#{puree.cached_cost_per_kg.round(2)}€/kg (sous-recette)"

# --- Poulet rôti aux légumes (avec sous-recette) ---
poulet = christophe.recipes.find_or_initialize_by(name: 'Poulet rôti aux légumes')
poulet.assign_attributes(
  description: 'Poulet fermier rôti avec pommes de terre, oignons et purée de carottes.',
  cooking_loss_percentage: 20,
  sellable_as_component: false,
  has_tray: false
)
poulet.save!

poulet_components = [
  { component: products['Poulet entier'],   type: 'Product', quantity_kg: 1.5 },
  { component: products['Pommes de terre'], type: 'Product', quantity_kg: 0.8 },
  { component: products['Oignons'],         type: 'Product', quantity_kg: 0.3 },
  { component: products['Huile d\'olive'],  type: 'Product', quantity_kg: 0.05 },
  { component: puree,                       type: 'Recipe',  quantity_kg: 0.5 }
]

poulet_components.each do |data|
  comp = poulet.recipe_components.find_or_initialize_by(
    component_type: data[:type],
    component_id: data[:component].id
  )
  comp.assign_attributes(quantity_kg: data[:quantity_kg])
  comp.save!
end

Recipes::Recalculator.call(poulet)
poulet.reload
puts "   Poulet rôti aux légumes : #{poulet.cached_total_cost.round(2)}€ | #{poulet.cached_cost_per_kg.round(2)}€/kg"

# --- Gratin dauphinois (avec barquette) ---
gratin = christophe.recipes.find_or_initialize_by(name: 'Gratin dauphinois')
gratin.assign_attributes(
  description: 'Gratin dauphinois traditionnel, crémeux et doré.',
  cooking_loss_percentage: 10,
  sellable_as_component: false,
  has_tray: true,
  tray_size: tray_sizes['Plat traiteur 10 personnes']
)
gratin.save!

gratin_components = [
  { component: products['Pommes de terre'], quantity_kg: 1.0 },
  { component: products['Crème fraîche'],   quantity_kg: 0.5 },
  { component: products['Beurre'],          quantity_kg: 0.05 },
  { component: products['Oeuf'],            quantity_kg: 0.18 },
  { component: products['Sel fin'],         quantity_kg: 0.01 }
]

gratin_components.each do |data|
  comp = gratin.recipe_components.find_or_initialize_by(
    component_type: 'Product',
    component_id: data[:component].id
  )
  comp.assign_attributes(quantity_kg: data[:quantity_kg])
  comp.save!
end

Recipes::Recalculator.call(gratin)
gratin.reload
puts "   Gratin dauphinois : #{gratin.cached_total_cost.round(2)}€ | " \
     "#{gratin.cached_cost_per_kg.round(2)}€/kg (avec barquette)"

# =============================================================================
# 7. PLATS DU JOUR (pour Christophe)
# =============================================================================
puts "\n7. Création des plats du jour..."

daily_specials_data = [
  { item_name: 'Filet mignon de porc', category: 'meat', cost_per_kg: 12.50, entry_date: Date.today },
  { item_name: 'Dos de cabillaud',       category: 'fish', cost_per_kg: 18.00, entry_date: Date.today },
  { item_name: 'Ratatouille maison',     category: 'side', cost_per_kg: 4.50,  entry_date: Date.today },
  { item_name: 'Bavette d\'aloyau',      category: 'meat', cost_per_kg: 15.80, entry_date: 1.day.ago.to_date },
  { item_name: 'Pavé de saumon grillé',  category: 'fish', cost_per_kg: 21.50, entry_date: 1.day.ago.to_date },
  { item_name: 'Gratin de courgettes',   category: 'side', cost_per_kg: 3.80,  entry_date: 1.day.ago.to_date }
]

daily_specials_data.each do |data|
  ds = christophe.daily_specials.find_or_initialize_by(
    item_name: data[:item_name],
    entry_date: data[:entry_date]
  )
  ds.assign_attributes(category: data[:category], cost_per_kg: data[:cost_per_kg])
  ds.save!
  puts "   #{data[:item_name]} (#{data[:category]}) — #{data[:cost_per_kg]}€/kg"
end

# =============================================================================
# 8. INVITATION DE DÉMONSTRATION
# =============================================================================
puts "\n8. Invitation de démonstration..."

demo_invitation = Invitation.find_or_initialize_by(email: 'demo@example.com')
if demo_invitation.new_record?
  demo_invitation.created_by_admin = admin
  demo_invitation.save!
  puts '   Invitation créée pour: demo@example.com'
  puts "   Token: #{demo_invitation.token}"
  puts "   URL: http://localhost:3000/signup?token=#{demo_invitation.token}"
else
  puts '   Invitation existante pour: demo@example.com'
end

# =============================================================================
# RÉSUMÉ
# =============================================================================
puts "\n#{'=' * 60}"
puts 'Seeds terminés !'
puts '=' * 60
puts ''
puts 'Comptes de test (mot de passe: password123) :'
puts '  admin@costchef.fr        → admin + abonnement actif'
puts '  christophe@traiteur.fr   → données de démo complètes'
puts '  laurent@nouveau.fr       → sans abonnement (test gating)'
puts ''
puts 'Données de Christophe :'
puts "  #{christophe.suppliers.count} fournisseurs"
puts "  #{christophe.products.count} produits"
puts "  #{christophe.products.sum { |p| p.product_purchases.count }} achats"
puts "  #{christophe.tray_sizes.count} barquettes"
puts "  #{christophe.recipes.count} recettes"
puts "  #{christophe.daily_specials.count} plats du jour"
