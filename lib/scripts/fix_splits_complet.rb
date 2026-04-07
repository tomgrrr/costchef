# encoding: utf-8
# frozen_string_literal: true
# Split complet des 14 produits — basé sur désignations factures Excel

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

def find_or_create_product(user, nom)
  p = user.products.where("name = ?", nom).first
  unless p
    p = user.products.create!(name: nom)
    puts "    ✨ Créé : '#{nom}' (ID #{p.id})"
  end
  p
end

def move_pps(ids, target, source_name)
  ids.each do |id|
    pp = ProductPurchase.find_by(id: id)
    next puts "    ⚠️  PP##{id} introuvable" unless pp
    pp.update!(product: target)
  end
  Products::AvgPriceRecalculator.call(target)
  puts "    ✅ #{ids.size} condits → '#{target.name}' (avg #{target.reload.avg_price_per_kg.to_f.round(3)} €/kg)"
end

def cleanup(product, label)
  reste = product.product_purchases.count
  rc    = product.recipe_components.count
  if reste == 0 && rc == 0
    product.destroy!
    puts "  🗑️  '#{label}' supprimé (vide)"
  elsif reste == 0
    puts "  ℹ️  '#{label}' gardé — #{rc} lien(s) recette"
  else
    puts "  ℹ️  '#{label}' — #{reste} condit(s) restant(s)"
  end
end

puts "\n=========================================="
puts "SPLIT CHAMPIGNONS BILLES"
puts "=========================================="
# PP rester : 3399, 3400, 3401 (champignons miniatures, 3€/kg)
morilles    = user.products.where("name ILIKE ?", "Morilles").first || find_or_create_product(user, "Morilles")
trompettes  = find_or_create_product(user, "Trompette de la mort")
move_pps([3402, 3403], morilles,   "Champignons billes")
move_pps([3404, 3405], trompettes, "Champignons billes")

puts "\n=========================================="
puts "SPLIT AIL"
puts "=========================================="
src = user.products.find_by("name ILIKE ?", "Ail")
ail_entier  = find_or_create_product(user, "Ail entier")
ail_hache   = find_or_create_product(user, "Ail haché surgelé")
ail_semoule = find_or_create_product(user, "Ail semoule")
move_pps([3366, 3367], ail_entier,  "Ail")
move_pps([3368, 3369, 3370, 3372, 3373, 3374, 3375], ail_hache, "Ail")
move_pps([3371], ail_semoule, "Ail")
cleanup(src, "Ail") if src

puts "\n=========================================="
puts "SPLIT ÉCHALOTE"
puts "=========================================="
src = user.products.find_by("name ILIKE ?", "Echalote")
echalote       = find_or_create_product(user, "Échalote")
pulpe_echalote = find_or_create_product(user, "Pulpe échalote")
ech_hachee     = find_or_create_product(user, "Échalote hachée surgelée")
move_pps([3423], echalote,       "Echalote")
move_pps([3424, 3425], pulpe_echalote, "Echalote")
move_pps([3426, 3427, 3428, 3429, 3430], ech_hachee, "Echalote")
cleanup(src, "Echalote") if src

puts "\n=========================================="
puts "SPLIT OIGNONS"
puts "=========================================="
src = user.products.find_by("name ILIKE ?", "Oignons")
oig_entier  = find_or_create_product(user, "Oignons entier")
oig_surg    = find_or_create_product(user, "Oignons émincés surgelés")
oig_prefrit = find_or_create_product(user, "Oignons émincés préfrits")
oig_emince  = find_or_create_product(user, "Oignons émincés")
move_pps([3467, 3468], oig_entier,  "Oignons")
move_pps([3469], oig_surg,    "Oignons")
move_pps([3473, 3474, 3475, 3476], oig_prefrit, "Oignons")
move_pps([3470, 3471, 3472], oig_emince, "Oignons")
cleanup(src, "Oignons") if src

puts "\n=========================================="
puts "SPLIT SAUMON"
puts "=========================================="
src = user.products.find_by("name ILIKE ?", "Saumon")
tr_saumon     = find_or_create_product(user, "TR saumon fumé")
saumon_frais  = find_or_create_product(user, "Saumon frais écossais")
chutes_saumon = find_or_create_product(user, "Chutes saumon fumé")
move_pps([3601, 3602, 3603, 3604, 3605, 3606, 3607], tr_saumon,     "Saumon")
move_pps([3612, 3613], saumon_frais,  "Saumon")
move_pps([3608, 3609, 3610, 3611], chutes_saumon, "Saumon")
cleanup(src, "Saumon") if src

puts "\n=========================================="
puts "SPLIT THON"
puts "=========================================="
src = user.products.find_by("name ILIKE ?", "Thon")
thon_longe   = find_or_create_product(user, "Thon longe")
thon_morceau = find_or_create_product(user, "Thon morceau naturel")
move_pps([3628, 3629, 3630, 3631, 3632, 3633], thon_longe,   "Thon")
move_pps([3634, 3635], thon_morceau, "Thon")
cleanup(src, "Thon") if src

puts "\n=========================================="
puts "SPLIT POIREAUX"
puts "=========================================="
src = user.products.find_by("name ILIKE ?", "Poireaux")
poir_coupes = find_or_create_product(user, "Poireaux coupés")
poir_vina   = find_or_create_product(user, "Poireaux vinaigrette")
move_pps([3478, 3479, 3482, 3483, 3484, 3485, 3486, 3487], poir_coupes, "Poireaux")
move_pps([3480, 3481], poir_vina, "Poireaux")
cleanup(src, "Poireaux") if src

puts "\n=========================================="
puts "SPLIT COURGETTE"
puts "=========================================="
src = user.products.find_by("name ILIKE ?", "Courgette")
courgette      = find_or_create_product(user, "Courgettes")
courgette_prep = find_or_create_product(user, "Courgettes préparées")
move_pps([3414, 3415, 3416, 3417], courgette,      "Courgette")
move_pps([3418, 3419], courgette_prep, "Courgette")
cleanup(src, "Courgette") if src

puts "\n=========================================="
puts "SPLIT TOMATES"
puts "=========================================="
src = user.products.find_by("name ILIKE ?", "Tomates")
tomates      = find_or_create_product(user, "Tomates")
tomate_ceri  = find_or_create_product(user, "Tomate cerise")
tomate_pelee = find_or_create_product(user, "Tomate pelée concassée")
# Tomates fraîches Jallet (>2€/kg)
move_pps([3505, 3506, 3507, 3508, 3509, 3510, 3512], tomates,      "Tomates")
# Tomate cerise Jallet (1.75€/kg)
move_pps([3511, 3513], tomate_ceri,  "Tomates")
# Tomate pelée concassée ABP
move_pps([3515, 3516, 3517, 3518], tomate_pelee, "Tomates")
cleanup(src, "Tomates source") if src && src.id != tomates.id

puts "\n=========================================="
puts "SPLIT MÉLANGE"
puts "=========================================="
src = user.products.find_by("name = ?", "Mélange")
leg_couscous = find_or_create_product(user, "Légumes couscous")
mel_legumes  = find_or_create_product(user, "Mélange légumes")
move_pps([3464], leg_couscous, "Mélange")
move_pps([3462, 3463], mel_legumes, "Mélange")
puts "  ℹ️  PP#3465 (France frais 261.9€/kg) et PP#3466 (Colin 56.9€/kg) laissés dans 'Mélange' — à identifier"

puts "\n=========================================="
puts "SPLIT SURIMI"
puts "=========================================="
src = user.products.find_by("name ILIKE ?", "Surimi")
surimi_bat  = find_or_create_product(user, "Surimi bâtonnet")
surimi_roul = find_or_create_product(user, "Surimi roulé")
move_pps([3626, 3627], surimi_bat,  "Surimi")
move_pps([3625], surimi_roul, "Surimi")
cleanup(src, "Surimi") if src

puts "\n=========================================="
puts "SPLIT MOULE"
puts "=========================================="
src = user.products.find_by("name ILIKE ?", "Moule")
moule_ent  = find_or_create_product(user, "Moule entière")
moule_deco = find_or_create_product(user, "Moule décoquillée")
move_pps([3587, 3588, 3589], moule_ent,  "Moule")
move_pps([3590, 3591], moule_deco, "Moule")
cleanup(src, "Moule") if src

puts "\n=========================================="
puts "SPLIT CREVETTES"
puts "=========================================="
src = user.products.find_by("name ILIKE ?", "Crevettes")
crev_dec      = find_or_create_product(user, "Crevettes décortiquées")
crev_semi_dec = find_or_create_product(user, "Crevettes semi-décortiquées")
move_pps([3539, 3541, 3544, 3545, 3546], crev_dec,      "Crevettes")
move_pps([3540, 3542, 3543], crev_semi_dec, "Crevettes")
cleanup(src, "Crevettes") if src

puts "\n=========================================="
puts "SPLIT CAROTTE"
puts "=========================================="
src = user.products.find_by("name ILIKE ?", "Carotte")
carotte_ent  = find_or_create_product(user, "Carotte entière")
carotte_prep = find_or_create_product(user, "Carotte préparée")
move_pps([3386, 3387, 3388], carotte_ent,  "Carotte")
move_pps([3385], carotte_prep, "Carotte")
cleanup(src, "Carotte") if src

puts "\n=========================================="
puts "TERMINÉ"
puts "=========================================="
