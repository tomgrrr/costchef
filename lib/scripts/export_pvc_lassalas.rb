# encoding: utf-8
# Export prix de vente conseillés Lassalas — recettes finales uniquement.
# Sortie CSV (séparateur ;) pour comparaison avec le top 100 client.

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")
abort "User introuvable" unless user

puts "nom;prix_vente_conseille;unite"

recipes = user.recipes
              .where(sellable_as_component: false)
              .includes(:tray_size)
              .order(:name)

recipes.each do |r|
  if r.sold_by_unit
    price = r.unit_selling_price
    unite = "€/unité"
  elsif r.has_tray
    price = r.suggested_selling_price
    unite = "€/barquette"
  else
    price = r.suggested_selling_price
    unite = "€/kg"
  end

  name      = %("#{r.name.gsub('"', '""')}")
  price_str = price ? format("%.2f", price).tr(".", ",") : ""

  puts "#{name};#{price_str};#{unite}"
end

puts ""
puts "# #{recipes.count} recettes finales — markup #{user.markup_coefficient}x"
