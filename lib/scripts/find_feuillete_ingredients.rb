# encoding: utf-8
# Cherche les noms réels des ingrédients introuvables dans la base Lassalas

user = User.find_by("email ILIKE ?", "dp.lassalas@outlook.fr")
abort "User not found" unless user

SEARCHES = {
  "Moules"           => %w[moule moul],
  "Ecrevisses"       => %w[ecrevisse écrevisse creviss],
  "Pétoncles"        => %w[petoncle pétoncle coquille saint],
  "Echalote"         => %w[echalot échalot],
  "Quenelles saumon" => %w[quenelle saumon],
  "Fumet crustacé"   => %w[fumet crustac],
  "Fumet homard"     => %w[fumet homard],
  "Fumet écrevisse"  => %w[fumet ecreviss écreviss langoustine],
  "Blanc poulet"     => %w[poulet blanc filet volaille],
  "Sauce champignons"=> %w[champignon sauce],
}.freeze

SEARCHES.each do |label, terms|
  puts "\n🔍 '#{label}'"

  found_products = terms.flat_map { |t|
    user.products.where("name ILIKE ?", "%#{t}%").map { |p| "  P #{p.id}\t#{p.name}" }
  }.uniq

  found_recipes = terms.flat_map { |t|
    user.recipes.where("name ILIKE ?", "%#{t}%").map { |r| "  R #{r.id}\t#{r.name}" }
  }.uniq

  if found_products.any? || found_recipes.any?
    (found_products + found_recipes).each { |l| puts l }
  else
    puts "  ❌ Rien trouvé"
  end
end
