# encoding: utf-8
# frozen_string_literal: true
# Audit des produits onglet Sauce — liste PP_ID, fournisseur, qty, prix, €/kg

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

# Mots-clés issus des désignations de l'onglet Sauce du fichier Excel
keywords = %w[
  concentr fond fumet pesto roux
  sauce tomatina moutard nuoc
  écrevisse armoricaine girolle crustac champignon morille
  saint.jac beurr.blanc paell langoustin
]

produits = keywords.flat_map do |kw|
  user.products.where("name ILIKE ?", "%#{kw}%").to_a
end.uniq { |p| p.id }.sort_by(&:name)

if produits.empty?
  puts "Aucun produit trouvé."
  exit
end

puts "\n#{'=' * 75}"
puts "AUDIT PRODUITS ONGLET SAUCE (#{produits.size} produits trouvés)"
puts "#{'=' * 75}"

produits.each do |p|
  condits = p.product_purchases.includes(:supplier).order(:price_per_kg)
  rc_count = p.recipe_components.count
  flag = condits.count == 0 ? "  ⚠️  0 CONDIT" : ""
  puts "\n  #{p.name} (ID #{p.id}) — #{condits.count} condit(s) | #{rc_count} recette(s) | avg #{p.avg_price_per_kg.to_f.round(3)} €/kg#{flag}"
  if condits.any?
    puts "    #{'%-5s  %-20s  %8s  %-5s  %10s  %8s' % ['PP_ID', 'Fournisseur', 'Qté', 'Unité', 'Prix total', '€/kg']}"
    condits.each do |c|
      puts "    #{'%-5s  %-20s  %8.3f  %-5s  %10.2f€  %8.3f' % [c.id, c.supplier&.name.to_s, c.package_quantity.to_f, c.package_unit.to_s, c.package_price.to_f, c.price_per_kg.to_f]}"
    end
  end
end

puts "\n#{'=' * 75}"
