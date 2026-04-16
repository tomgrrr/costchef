# encoding: utf-8
# Prix de vente conseillés — toutes les recettes finales Lassalas
# Colonnes : ID | Nom | Coût/kg | Markup | Prix conseillé/kg | Mode vente | Poids unité (kg) | Prix barquette | Prix conseillé unitaire

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")
abort "User introuvable" unless user

markup = user.markup_coefficient.to_f

puts "Markup coefficient : #{markup}x"
puts ""
puts "=== RECETTES FINALES (sellable_as_component: false) ==="
puts "ID\tNom\tCoût/kg\tMarkup\tPVC/kg\tMode\tPoids_unité_kg\tPrix_barquette\tPVC_unitaire"

user.recipes.where(sellable_as_component: false).includes(:tray_size).order(:name).each do |r|
  cost_kg     = r.cached_cost_per_kg.to_f.round(3)
  pvc_kg      = r.suggested_selling_price&.to_f&.round(3)
  tray_price  = r.has_tray && r.tray_size ? r.tray_size.price.to_f.round(2) : nil
  unit_weight = r.sold_by_unit ? r.unit_reference_weight_kg.to_f.round(3) : nil
  pvc_unit    = r.unit_selling_price&.to_f&.round(3)

  mode = if r.sold_by_unit
    "unité"
  elsif r.has_tray
    "barquette"
  else
    "kg"
  end

  puts [
    r.id,
    r.name,
    cost_kg,
    markup,
    pvc_kg || "n/a",
    mode,
    unit_weight || "",
    tray_price || "",
    pvc_unit || ""
  ].join("\t")
end

puts ""
puts "=== SOUS-RECETTES (sellable_as_component: true) — pas de PVC ==="
user.recipes.where(sellable_as_component: true).order(:name).each do |r|
  cost_kg = r.cached_cost_per_kg.to_f.round(3)
  puts "#{r.id}\t#{r.name}\t#{cost_kg} €/kg\t(composant interne)"
end

puts ""
total = user.recipes.count
puts "Total : #{total} recettes — Markup Lassalas : #{markup}x"
