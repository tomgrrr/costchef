# encoding: utf-8
# frozen_string_literal: true
# Découpe le produit "morceaux" en 17 produits distincts selon désignation facture

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

# Mapping : nom_produit => [pp_ids]
splits = {
  "Crépine"                           => [4096, 4097, 4098],
  "Echine porc avec os"               => [4099, 4100, 4101, 4102, 4103],
  "Filet mignon porc"                 => [4104, 4105, 4106, 4107, 4108],
  "Jambon paré sans crosse"           => [4114, 4115, 4116, 4117, 4118],
  "Longe porc"                        => [4128, 4129, 4130, 4131, 4132, 4133, 4134, 4135],
  "Panse porc"                        => [4137],
  "Pieds de porc"                     => [4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145, 4146, 4147, 4148, 4149],
  "Bardes de porc"                    => [4093],
  "Bardière S/Couenne"                => [4094, 4095],
  "Foie de porc"                      => [4109, 4110],
  "Gorge porc S/couenne"              => [4111, 4112, 4113],
  "Jambonneau"                        => [4119, 4120, 4121, 4122],
  "Langons porc"                      => [4123, 4124, 4125, 4126, 4127],
  "Oreilles de porc"                  => [4136],
  "Poitrine cutter porc"              => [4150, 4151, 4152],
  "Poitrine parée porc"               => [4153, 4154],
  "Tête de porc S/langue S/cervelle"  => [4155, 4156, 4157, 4158, 4159],
}

puts "\n=== DÉCOUPAGE MORCEAUX ==="
morceaux = user.products.find_by("name = ?", "morceaux")
puts "Produit source : #{morceaux&.name} (ID #{morceaux&.id}) — #{morceaux&.product_purchases&.count} condits\n\n"

splits.each do |nom, pp_ids|
  # Trouver ou créer le produit cible
  produit = user.products.where("name ILIKE ?", nom).first
  if produit
    puts "  ♻️  Produit existant : '#{produit.name}' (ID #{produit.id})"
  else
    produit = user.products.create!(name: nom, unit: "kg")
    puts "  ✨ Créé : '#{produit.name}' (ID #{produit.id})"
  end

  # Déplacer les ProductPurchases
  pp_ids.each do |id|
    pp = ProductPurchase.find_by(id: id)
    unless pp
      puts "    ⚠️  PP##{id} introuvable"
      next
    end
    pp.update!(product: produit)
  end

  Products::AvgPriceRecalculator.call(produit)
  puts "    ✅ #{pp_ids.size} condit(s) transférés → avg #{produit.reload.avg_price_per_kg.to_f.round(3)} €/kg"
end

# Vérifier s'il reste des condits sur "morceaux"
if morceaux
  reste = morceaux.product_purchases.count
  rc = morceaux.recipe_components.count
  puts "\n--- Produit 'morceaux' après découpage ---"
  puts "  Condits restants : #{reste}"
  puts "  Liens recettes   : #{rc}"
  if reste == 0 && rc == 0
    morceaux.destroy!
    puts "  🗑️  Produit 'morceaux' supprimé"
  else
    puts "  ⚠️  Non supprimé (#{reste} condits, #{rc} liens recettes)"
  end
end

puts "\n=== TERMINÉ ==="
