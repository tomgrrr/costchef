# encoding: utf-8
# Script de diagnostic — trouve les IDs produits pour le lot conditionnements factures
# Produits à pricer : moutarde, moutarde charroux, vinaigre balsamique, ketchup,
#                     foie gras, ratatouille, morilles, ricard, jus orange

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")
abort "User introuvable" unless user

puts "=== DIAGNOSTIC PRODUITS POUR CONDITIONNEMENTS FACTURES ==="
puts ""

SEARCHES = [
  ["Moutarde (classique/Amora)",     ["moutarde"]],
  ["Moutarde de Charroux",            ["charroux"]],
  ["Vinaigre Balsamique",             ["balsamique"]],
  ["Ketchup",                         ["ketchup"]],
  ["Foie Gras",                       ["foie gras", "foie"]],
  ["Ratatouille",                     ["ratatouille"]],
  ["Morilles",                        ["morille"]],
  ["Ricard",                          ["ricard"]],
  ["Jus d'orange",                    ["jus d'orange", "jus orange"]],
].freeze

SEARCHES.each do |label, terms|
  puts "--- #{label} ---"
  found = []
  terms.each do |term|
    user.products.where("name ILIKE ?", "%#{term}%").each do |p|
      found << p unless found.any? { |x| x.id == p.id }
    end
  end

  if found.empty?
    puts "  ✗ INTROUVABLE"
  else
    found.each do |p|
      pp_count = p.product_purchases.count
      pp_info  = p.product_purchases.first
      puts "  ID #{p.id} | #{p.name} | base_unit: #{p.base_unit} | #{pp_count} cond. existants"
      if pp_info
        sup = pp_info.supplier&.name || "—"
        puts "         Premier cond : #{pp_info.package_quantity}#{pp_info.package_unit} | #{pp_info.package_price}€ | #{sup}"
      end
    end
  end
  puts ""
end

puts "=== FOURNISSEURS DISPONIBLES (filtrés) ==="
["france frais", "transgourmet", "brendani", "ds restauration", "délices", "metro", "jallet"].each do |term|
  s = user.suppliers.where("name ILIKE ?", "%#{term}%").first
  if s
    puts "  ID #{s.id} | #{s.name}"
  else
    puts "  '#{term}' → à créer"
  end
end
