# encoding: utf-8
# frozen_string_literal: true
# Split onglet Sauce : 36 conditionnements mal placés dans Morilles → produits distincts
# Seuls PP#3402 et 3403 (Délices des bois) restent dans Morilles (vraies morilles)

user = User.find_by!("email ILIKE ?", "dp.lassalas@outlook.fr")

def find_or_create_product(user, nom)
  p = user.products.where("name = ?", nom).first
  unless p
    p = user.products.create!(name: nom)
    puts "    ✨ Créé : '#{nom}' (ID #{p.id})"
  end
  p
end

def move_pps(ids, target)
  moved = 0
  ids.each do |id|
    pp = ProductPurchase.find_by(id: id)
    next puts "    ⚠️  PP##{id} introuvable (déjà déplacé ?)" unless pp
    pp.update!(product: target)
    moved += 1
  end
  Products::AvgPriceRecalculator.call(target)
  target.reload
  puts "    ✅ #{moved}/#{ids.size} condit(s) → '#{target.name}' (avg #{target.avg_price_per_kg.to_f.round(3)} €/kg)"
end

morilles = user.products.find_by!(id: 1015)
puts "=== SPLIT MORILLES ===  (#{morilles.product_purchases.count} condits avant)"

# ── ABP ───────────────────────────────────────────────────────────────────
puts "\n-- ABP --"
concentre = user.products.find_by(id: 1099) || find_or_create_product(user, "Concentré de tomates")
move_pps([3947, 3948], concentre)

# ── Colin ─────────────────────────────────────────────────────────────────
puts "\n-- Colin --"
fond_veau       = user.products.find_by(id: 1120) || find_or_create_product(user, "Fond de veau")
fond_volaille   = user.products.find_by(id: 1049) || find_or_create_product(user, "Fond de volaille")
fond_veau_glace = find_or_create_product(user, "Fond de veau en glace")
fumet_homard    = user.products.find_by(id: 1063) || find_or_create_product(user, "Fumet de homard")
pesto_vert      = find_or_create_product(user, "Pesto vert")
fumet_poisson   = find_or_create_product(user, "Fumet de poisson")
fumet_poisson_g = find_or_create_product(user, "Fumet de poisson en glace")
fumet_lang      = user.products.find_by(id: 1066) || find_or_create_product(user, "Fumet de langoustine")
melange_paella  = user.products.where("name ILIKE ?", "%pa%lla%").first || find_or_create_product(user, "Mélange paëlla")
roux_blanc      = find_or_create_product(user, "Roux blanc")
sauce_ecrevisse = user.products.find_by(id: 1113) || find_or_create_product(user, "Sauce écrevisse")
sauce_armori    = find_or_create_product(user, "Sauce armoricaine")
sauce_cepes     = find_or_create_product(user, "Sauce aux cèpes")
sauce_crustaces = find_or_create_product(user, "Sauce aux crustacés")
sauce_champi    = find_or_create_product(user, "Sauce aux champignons")
sauce_morilles  = find_or_create_product(user, "Sauce aux morilles")
sauce_girolles  = user.products.find_by(id: 1067) || find_or_create_product(user, "Sauce girolles")
sauce_stjacques = find_or_create_product(user, "Sauce aux saint-jacques")
sauce_tomatina  = user.products.find_by(id: 1064) || find_or_create_product(user, "Sauce tomatina")
sauce_bb        = find_or_create_product(user, "Sauce beurre blanc")

move_pps([3949],       fond_veau)
move_pps([3950],       fond_volaille)
move_pps([3951],       fond_veau_glace)
move_pps([3952],       fumet_homard)
move_pps([3953],       pesto_vert)
move_pps([3954],       fumet_poisson)
move_pps([3955],       fumet_poisson_g)
move_pps([3956],       fumet_lang)        # Jus de langoustine en pâte
move_pps([3957],       melange_paella)    # Mélange pour paëlla
move_pps([3958],       roux_blanc)
move_pps([3959],       sauce_ecrevisse)
move_pps([3960],       sauce_armori)
move_pps([3961],       sauce_cepes)
move_pps([3963],       sauce_crustaces)
move_pps([3964],       sauce_champi)
move_pps([3965, 3966], sauce_morilles)
move_pps([3967],       sauce_girolles)
move_pps([3968],       sauce_stjacques)
move_pps([3969],       sauce_tomatina)
move_pps([3989, 3990, 3991], sauce_bb)

# ── France frais ──────────────────────────────────────────────────────────
puts "\n-- France frais --"
moutarde_charroux  = find_or_create_product(user, "Moutarde de Charroux")
moutarde_dijon     = find_or_create_product(user, "Moutarde dijon")
sauce_peperonata   = find_or_create_product(user, "Sauce peperonata")
sauce_tomate_gus   = find_or_create_product(user, "Sauce tomate gustosa")

move_pps([3970, 3971], fond_veau)          # Fond blanc veau déshydraté → même produit
move_pps([3972],       fond_volaille)      # Fond blanc volaille déshydraté → même produit
move_pps([3973],       moutarde_charroux)
move_pps([3976],       moutarde_dijon)
move_pps([3979],       sauce_peperonata)
move_pps([3980],       sauce_tomate_gus)

# ── Sysco ─────────────────────────────────────────────────────────────────
puts "\n-- Sysco --"
sauce_huitre = find_or_create_product(user, "Sauce huître")
nuoc_mam     = find_or_create_product(user, "Nuoc mam")

move_pps([3983], sauce_huitre)
move_pps([3984], nuoc_mam)

# ── Transgourmet ──────────────────────────────────────────────────────────
puts "\n-- Transgourmet --"
moutarde_ancienne = find_or_create_product(user, "Moutarde à l'ancienne")

move_pps([3986], moutarde_dijon)     # Moutarde dijon Transgourmet → même produit
move_pps([3988], moutarde_ancienne)

# ── Recalcul Morilles ─────────────────────────────────────────────────────
Products::AvgPriceRecalculator.call(morilles)
morilles.reload
puts "\n=== Morilles après split : #{morilles.product_purchases.count} condit(s) ==="
morilles.product_purchases.includes(:supplier).each do |pp|
  puts "  PP##{pp.id} | #{pp.supplier&.name} | #{pp.package_quantity}#{pp.package_unit} | #{pp.package_price}€ | #{pp.price_per_kg.to_f.round(3)} €/kg"
end
puts "  avg Morilles → #{morilles.avg_price_per_kg.to_f.round(3)} €/kg"
puts "\n=== TERMINÉ ==="
