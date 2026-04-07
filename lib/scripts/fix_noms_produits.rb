# encoding: utf-8
# frozen_string_literal: true
# Renomme les produits avec noms suspects : tronqués, abrégés, références fournisseur, casse

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

renames = {
  # Noms tronqués / abrégés
  "Tartare t"                    => "Tartare tomate",
  "cord. bleu dinde"             => "Cordon bleu dinde",
  "Cord. bleu poulet"            => "Cordon bleu poulet",
  "Long"                         => "Riz long",
  "tatin"                        => "Tarte tatin",
  "canelé"                       => "Canelé",
  "coq au vin"                   => "Coq au vin",
  "chapelure"                    => "Chapelure",
  "viennoiseries"                => "Viennoiseries",
  "choc"                         => "Chocolat noir",
  "pois chiche"                  => "Pois chiche",
  "AIL"                          => "Ail",
  "AV CAPA"                      => "Avant caparaçon boeuf",
  "Basmati"                      => "Riz Basmati",
  "Thaï"                         => "Riz thaï",

  # Références fournisseur dans le nom
  "Huile tournesol sye BI5L"     => "Huile Tournesol",
  "Purée carottes CE2 B"         => "Purée carotte",
  "privilege margarine tourage pl" => "Margarine",
  "Purée potimarron bio 2,5K"    => "Purée potimarron",
  "mayonnise tube175g lesieur x8" => "Mayonnaise",

  # Capitalisations / noms incomplets
  "Lasagne"                      => "Lasagnes",
  "Haricots"                     => "Haricots verts",
  "Nouilles"                     => "Nouilles riz",
  "Mozza"                        => "Mozza cossette",
  "Loup"                         => "Dos loup de mer",
  "Egrene de boeuf"              => "Egrene boeuf",
}

puts "\n=== RENOMMAGE DES PRODUITS ==="
ok = 0
skip = 0

renames.each do |ancien, nouveau|
  p = user.products.find_by("name = ?", ancien)
  unless p
    puts "  ⚠️  Introuvable (exact) : '#{ancien}'"
    skip += 1
    next
  end

  # Vérifier qu'un produit avec le nouveau nom n'existe pas déjà
  existant = user.products.where("name = ? AND id != ?", nouveau, p.id).first
  if existant
    puts "  ⚠️  '#{nouveau}' existe déjà (ID #{existant.id}) — fusion nécessaire, ignoré pour l'instant"
    skip += 1
    next
  end

  p.update!(name: nouveau)
  puts "  ✅ #{ancien.ljust(40)} → #{nouveau}"
  ok += 1
end

# Cas particulier : "Thon" → deux produits dans Excel (longe vs morceau)
# On garde le nom générique "Thon" pour l'instant (à splitter manuellement)
puts "\n  ℹ️  'Thon' laissé en l'état — 2 variantes Excel (longe / morceau naturel), à confirmer"

puts "\n=== RÉSULTAT : #{ok} renommés, #{skip} ignorés ==="
