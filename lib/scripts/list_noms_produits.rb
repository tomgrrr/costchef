# encoding: utf-8
# frozen_string_literal: true
# Liste tous les noms de produits en base pour audit des noms suspects

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")
products = user.products.order(:name)

puts "\n=== #{products.count} PRODUITS EN BASE ==="
puts "%-5s  %-45s  %s" % ["ID", "Nom", "Nb condits"]
puts "-" * 70
products.each do |p|
  nb = p.product_purchases.count
  puts "%-5s  %-45s  %d" % [p.id, p.name, nb]
end
