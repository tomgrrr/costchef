# frozen_string_literal: true

# Production import script for user dp.lassalas@outlook.fr
# Run with: rails runner tmp/import/prod_import.rb
#
# This script is self-contained. No external files needed.

EMAIL = "dp.lassalas@outlook.fr"

DATA = <<~'EXPORT_DATA'
S|Sysco|true
S|Jallet|true
S|France frais|true
S|ABP|true
S|Metro|true
S|Magpra|true
S|Transgourmet|true
S|DS restauration|true
S|Trapon champignons|true
S|Cap traiteur|true
S|Délices des bois|true
S|Ribeyron|true
S|Grelet|true
S|Colin|true
S|Coboma|true
S|SAS frais livré|true
S|GAEC fournier|true
S|Moulin de massagettes|true
S|Ronchetti|true
S|La bovida|true
S|Cantal salaisons|true
S|Limoujoux|true
S|Scavi|true
S|Tradival|true
S|Allier volailles|true
S|Moy frais|true
S|CdP|true
S|Fournil de jean|true
P|Ananas|kg||6.9472|false|
P|Grenade|kg||2.19|false|
P|Banane|kg||2.1177|false|
P|Citron|kg||2.8758|false|
P|Framboise|kg||5.5215|false|
P|Clementine|kg||3.25|false|
P|Fraise|kg||5.6455|false|
P|Kiwi|kg||0.51|false|
P|Raisin|kg||4.5608|false|
P|Passion|kg||13.5125|false|
P|Pomme|kg||1.7707|false|
P|Olive|kg||4.2422|false|
P|Abricot|kg||3.7727|false|
P|Mirabelle|kg||3.2775|false|
P|Prunes|kg||3.2625|false|
P|Poires|kg||3.3017|false|
P|Myrtille|kg||11.3836|false|
P|Pomelos|kg||0.7|false|
P|Melon|kg||2.0967|false|
P|Peche|kg||2.75|false|
P|AIL|kg||11.2907|false|
P|Asperges|kg||16.485|false|
P|Betterave|kg||1.1667|false|
P|Butternut|kg||2.0|false|
P|Carotte|kg||1.6214|false|
P|Celeri remoulade|kg||4.4439|false|
P|Champi|kg||10.94|false|
P|Champignons billes|kg||41.9481|false|
P|Chou|kg||2.573|false|
P|Chou-fleur|kg||3.7704|false|
P|cornichons|kg||10.6375|false|
P|Courgette|kg||2.1426|false|
P|endive|kg||7.7927|false|
P|Echalote|kg||6.5221|false|
P|Epinard|kg||3.836|false|
P|Gingembre|kg||7.0|false|
P|Haricots|kg||3.895|false|
P|Lentilles|kg||1.807|false|
P|Macédoine|kg||2.2|false|
P|Maïs|kg||4.9076|false|
P|Mélange|kg||19.2634|false|
P|Oignons|kg||2.5922|false|
P|Patate douce|kg||3.75|false|
P|Poireaux|kg||2.0514|false|
P|pois chiche|kg||1.2978|false|
P|Petits pois|kg||4.9|false|
P|Poivrons|kg||3.4919|false|
P|PDT|kg||1.7|false|
P|Ratatouille|kg||3.9|false|
P|Salade|kg||0.95|false|
P|Tomates|kg||2.6957|false|
P|Julienne|kg||2.8|false|
P|Bar|kg||18.9|false|
P|Bonite|kg||15.7|false|
P|Cabillaud|kg||16.766|false|
P|Crevettes|kg||18.4578|false|
P|Ecrevisse|kg||20.525|false|
P|Eglefin|kg||13.9|false|
P|Fletan|kg||19.3|false|
P|Gambas|kg||14.75|false|
P|Lieu|kg||16.9|false|
P|Limande|kg||12.4|false|
P|Lotte|kg||27.1431|false|
P|Loup|kg||13.9|false|
P|Merlan|kg||12.7304|false|
P|Merlu|kg||10.9|false|
P|Moule|kg||4.6|false|
P|Quenelle|kg||8.2837|false|
P|Saumon|kg||17.4856|false|
P|Sébaste|kg||15.5|false|
P|Sole|kg||12.1455|false|
P|St jacques|kg||41.92|false|
P|Surimi|kg||7.115|false|
P|Thon|kg||11.9368|false|
P|Cantal|kg||10.8836|false|
P|Mozza|kg||6.9373|false|
P|From. blanc|kg||3.5597|false|
P|Grana padano|kg||19.5442|false|
P|Emmental|kg||8.4994|false|
P|Chèvre|kg||15.1731|false|
P|Gruyère|kg||8.5868|false|
P|Lait|kg||0.742|false|
P|Beurre|kg||9.469|false|
P|Crème|kg||3.7501|false|
P|Basmati|kg||3.526|false|
P|Long|kg||2.4137|false|
P|Thaï|kg||2.8407|false|
P|Lasagne|kg||4.1|false|
P|Crozet|kg||1.4564|false|
P|Nouilles|kg||8.125|false|
P|Spaghetti|kg||3.1977|false|
P|Penne|kg||3.224|false|
P|Torti|kg||4.9736|false|
P|Fusili|kg||3.198|false|
P|Tagliatelle|kg||6.5071|false|
P|Cajou|kg||16.15|false|
P|Coco|kg||6.9617|false|
P|Noix|kg||19.4289|false|
P|Pistache|kg||51.03|false|
P|Noisette|kg||14.2|false|
P|Cacahuetes|kg||13.6|false|
P|Poivre|kg||21.31|false|
P|Sel|kg||0.3884|false|
P|Paprika|kg||28.75|false|
P|Thym|kg||1.05|false|
P|Persil|kg||28.5308|false|
P|Laurier|kg||1.05|false|
P|Oseille|kg||14.36|false|
P|H.Provence|kg||7.18|false|
P|Basilic|kg||15.56|false|
P|Estragon|kg||1.05|false|
P|Cerfeuil|kg||1.05|false|
P|Aneth|kg||1.05|false|
P|Cebette|kg||1.6|false|
P|Origan|kg||14.4919|false|
P|Vin rouge|l||5.1385|false|
P|Vin blanc|l||2.13|false|
P|Cognac|l||18.9533|false|
P|Porto|l||9.445|false|
P|Kirsch|l||16.42|false|
P|Vermouth|l||5.685|false|
P|Macardan|l||6.777|false|
P|Cuisson|piece|0.05|14.13|false|
P|Barquettes|piece|0.05|13.7531|false|
P|Farine de blé T55|kg||0.9571|false|
P|Aligot|kg||7.96|false|
P|Purée carottes CE2 B|kg||2.5|false|
P|Purée potimarron bio 2,5K|kg||4.3909|false|
P|Purée pdt|kg||25.97|false|
P|Sucre glace|kg||1.8521|false|
P|Sucre semoule|kg||1.5285|false|
P|Huile tournesol sye BI5L|l||2.1579|false|
P|Huile d'olive vierge extra|l||5.7806|false|
P|privilege margarine tourage pl|l||4.864|false|
P|Huile friture|l||3.1073|false|
P|Morilles|kg||17.1552|false|
P|mayonnise tube175g lesieur x8|kg||5.3071|false|
P|Tartare t|kg||8.5498|false|
P|Porc carcasse|kg||3.1051|false|
P|Sang|kg||1.45|false|
P|Chorizo|kg||10.6218|false|
P|morceaux|kg||3.0045|false|
P|AV CAPA|kg||9.8999|false|
P|Filet|kg||27.5991|false|
P|Noix de joue|kg||13.0|false|
P|Paleron|kg||12.4472|false|
P|Rond gite|kg||14.1047|false|
P|Langue|kg||17.7496|false|
P|Egrene|kg||11.7733|false|
P|Veau|kg||14.3886|false|
P|cord. bleu dinde|kg||13.2222|false|
P|Cord. bleu poulet|kg||12.9|false|
P|coq au vin|kg||9.8501|false|
P|Gésier|kg||7.9|false|
P|Canard|kg||14.5|false|
P|Poulet|kg||8.6851|false|
P|Dinde|kg||8.6301|false|
P|Oeuf solide|piece|0.05|5.9592|false|
P|Blanc|piece|0.05|97.0067|false|
P|Oeuf liquide entier|kg||4.9775|false|
P|Jaune|kg||8.9251|false|
P|viennoiseries|piece|0.05|5.8|false|
P|canelé|piece|0.05|11.1333|false|
P|choc|piece|0.05|61.6|false|
P|Charlotine|piece|0.05|40.0933|false|
P|Chouquette|piece|0.05|4.9667|false|
P|Crêpe|piece|0.05|10.5011|false|
P|Tiramisu|piece|0.05|29.8321|false|
P|Flan|piece|0.05|173.5143|false|
P|fond|piece|0.05|4.5281|false|
P|Moelleux|piece|0.05|342.2958|false|
P|tatin|piece|0.05|175.0667|false|
P|Tartelette|piece|0.05|37.4167|false|
P|Nougats|piece|0.05|530.25|false|
P|Muffin|piece|0.05|21.4143|false|
P|pain|piece|0.05|13.1185|false|
P|chapelure|kg||2.33|false|
P|Fécule|kg||0.0|false|
P|Poudre d'amandes|kg||0.0|false|
P|Vanille|kg||0.0|false|
P|Levure|kg||0.0|false|
P|Roux|kg||0.0|false|
P|Fumet de crustacés|kg||0.0|false|
P|Fumet de homard|kg||0.0|false|
P|Sauce tomatina|kg||0.0|false|
P|Muscade|kg||0.0|false|
P|Fumet de langoustine|kg||0.0|false|
P|Sauce girolles|kg||0.0|false|
P|Gratons|kg||0.0|false|
P|Améliorant|kg||0.0|false|
P|Farine de gruau|kg||0.0|false|
P|Jambon|kg||0.0|false|
P|Lardons|kg||0.0|false|
P|Poudre tomate|kg||0.0|false|
P|Chair à saucisse|kg||0.0|false|
P|Chair tomate|kg||0.0|false|
P|Piment|kg||0.0|false|
P|Poudre purée|kg||0.0|false|
P|Anchois|kg||0.0|false|
P|Ricard|l||0.0|false|
P|Nappage|kg||0.0|false|
P|Pied de cochon|kg||0.0|false|
P|Égrainés de bœuf|kg||0.0|false|
P|Gustoza|kg||0.0|false|
P|Riz US|kg||0.0|false|
P|Bol|piece|0.01|0.0|false|
P|Brisure de nougat|kg||0.0|false|
P|Vinaigre|l||0.0|false|
P|Ketchup|kg||0.0|false|
P|Mayonnaise|kg||0.0|false|
P|Vinaigre de vin|l||0.0|false|
P|Vinaigre balsamique|l||0.0|false|
P|Moutarde|kg||0.0|false|
P|Pâtes trois couleurs|kg||0.0|false|
P|Piment d'Espelette|kg||0.0|false|
P|Menthe fraîche|kg||0.0|false|
PP|Ananas|Sysco|3.0|kg|14.7|3.0|4.9|true
PP|Ananas|Sysco|3.0|kg|17.97|3.0|5.99|true
PP|Ananas|Jallet|1.2|kg|3.6|1.2|3.0|true
PP|Ananas|Jallet|1.2|kg|3.3|1.2|2.75|true
PP|Ananas|Jallet|2.0|kg|30.8|2.0|15.4|true
PP|Ananas|Jallet|2.0|kg|30.8|2.0|15.4|true
PP|Ananas|France frais|3.4|kg|21.76|3.4|6.4|true
PP|Ananas|France frais|5.1|kg|32.64|5.1|6.4|true
PP|Ananas|ABP|3.2|kg|16.3|3.2|5.0938|true
PP|Ananas|ABP|2.4|kg|12.23|2.4|5.0958|true
PP|Grenade|Metro|2.0|kg|4.38|2.0|2.19|true
PP|Banane|Metro|2.0|kg|6.98|2.0|3.49|true
PP|Banane|Jallet|1.6|kg|2.88|1.6|1.8|true
PP|Banane|Jallet|1.0|kg|1.95|1.0|1.95|true
PP|Banane|Jallet|3.4|kg|6.46|3.4|1.9|true
PP|Banane|Jallet|3.7|kg|7.03|3.7|1.9|true
PP|Banane|Jallet|2.4|kg|4.56|2.4|1.9|true
PP|Citron|Magpra|2.0|kg|4.18|2.0|2.09|true
PP|Citron|Magpra|1.0|kg|2.09|1.0|2.09|true
PP|Citron|Transgourmet|1.0|kg|3.75|1.0|3.75|true
PP|Citron|Jallet|0.4|kg|1.3|0.4|3.25|true
PP|Citron|Jallet|0.7|kg|2.28|0.7|3.2571|true
PP|Citron|Jallet|0.9|kg|3.38|0.9|3.7556|true
PP|Citron|Jallet|0.2|kg|0.85|0.2|4.25|true
PP|Framboise|Jallet|12.0|kg|39.0|12.0|3.25|true
PP|Framboise|Jallet|10.0|kg|32.5|10.0|3.25|true
PP|Framboise|Jallet|4.0|kg|14.0|4.0|3.5|true
PP|Framboise|Jallet|8.0|kg|28.0|8.0|3.5|true
PP|Framboise|Jallet|12.0|kg|33.0|12.0|2.75|true
PP|Framboise|Jallet|10.0|kg|32.5|10.0|3.25|true
PP|Framboise|Jallet|16.0|kg|44.0|16.0|2.75|true
PP|Framboise|Jallet|8.0|kg|28.0|8.0|3.5|true
PP|Framboise|Jallet|10.0|kg|30.0|10.0|3.0|true
PP|Framboise|Jallet|16.0|kg|48.0|16.0|3.0|true
PP|Framboise|Jallet|8.0|kg|24.0|8.0|3.0|true
PP|Framboise|ABP|4.0|kg|41.7|4.0|10.425|true
PP|Framboise|ABP|12.0|kg|125.09|12.0|10.4242|true
PP|Framboise|ABP|12.0|kg|125.09|12.0|10.4242|true
PP|Framboise|ABP|12.0|kg|125.09|12.0|10.4242|true
PP|Framboise|ABP|12.0|kg|125.09|12.0|10.4242|true
PP|Framboise|DS restauration|4.0|kg|43.6|4.0|10.9|true
PP|Clementine|Jallet|4.6|kg|14.95|4.6|3.25|true
PP|Clementine|Jallet|3.6|kg|11.7|3.6|3.25|true
PP|Fraise|Jallet|2.0|kg|20.0|2.0|10.0|true
PP|Fraise|Jallet|4.0|kg|19.0|4.0|4.75|true
PP|Fraise|Jallet|2.5|kg|25.0|2.5|10.0|true
PP|Fraise|Jallet|4.0|kg|20.0|4.0|5.0|true
PP|Fraise|Jallet|6.0|kg|28.5|6.0|4.75|true
PP|Fraise|Jallet|4.0|kg|19.0|4.0|4.75|true
PP|Fraise|Jallet|5.0|kg|23.75|5.0|4.75|true
PP|Kiwi|Jallet|20.0|kg|10.2|20.0|0.51|true
PP|Kiwi|Jallet|30.0|kg|15.3|30.0|0.51|true
PP|Raisin|Jallet|2.3|kg|10.93|2.3|4.7522|true
PP|Raisin|Jallet|2.6|kg|12.35|2.6|4.75|true
PP|Raisin|Jallet|2.2|kg|10.45|2.2|4.75|true
PP|Raisin|Jallet|2.9|kg|10.15|2.9|3.5|true
PP|Raisin|Jallet|2.5|kg|13.13|2.5|5.252|true
PP|Passion|Jallet|0.35|kg|4.73|0.35|13.5143|true
PP|Passion|Jallet|0.45|kg|6.08|0.45|13.5111|true
PP|Pomme|Jallet|3.0|kg|6.0|3.0|2.0|true
PP|Pomme|Jallet|3.8|kg|7.6|3.8|2.0|true
PP|Pomme|Jallet|2.6|kg|4.94|2.6|1.9|true
PP|Pomme|Jallet|3.9|kg|7.8|3.9|2.0|true
PP|Pomme|Jallet|90.9|kg|149.99|90.9|1.6501|true
PP|Pomme|Jallet|106.8|kg|186.9|106.8|1.75|true
PP|Pomme|ABP|1.0|kg|12.16|1.0|12.16|true
PP|Olive|France frais|3.0|kg|12.63|3.0|4.21|true
PP|Olive|France frais|3.0|kg|12.63|3.0|4.21|true
PP|Olive|France frais|3.0|kg|12.63|3.0|4.21|true
PP|Olive|ABP|3.0|kg|12.92|3.0|4.3067|true
PP|Olive|ABP|3.0|kg|12.92|3.0|4.3067|true
PP|Olive|France frais|3.0|kg|12.63|3.0|4.21|true
PP|Abricot|ABP|60.0|kg|225.5|60.0|3.7583|true
PP|Abricot|Jallet|3.8|kg|15.2|3.8|4.0|true
PP|Mirabelle|ABP|36.0|kg|117.99|36.0|3.2775|true
PP|Prunes|ABP|24.0|kg|78.3|24.0|3.2625|true
PP|Poires|ABP|24.0|kg|79.24|24.0|3.3017|true
PP|Myrtille|ABP|50.0|kg|510.0|50.0|10.2|true
PP|Myrtille|Trapon champignons|480.0|kg|5760.0|480.0|12.0|true
PP|Myrtille|ABP|200.0|kg|2040.0|200.0|10.2|true
PP|Pomelos|Jallet|4.0|kg|2.8|4.0|0.7|true
PP|Melon|Jallet|12.0|kg|25.2|12.0|2.1|true
PP|Melon|Jallet|6.0|kg|13.5|6.0|2.25|true
PP|Melon|Jallet|8.0|kg|15.2|8.0|1.9|true
PP|Melon|Jallet|4.0|kg|9.0|4.0|2.25|true
PP|Peche|Jallet|3.8|kg|10.45|3.8|2.75|true
PP|AIL|Jallet|0.2|kg|1.35|0.2|6.75|true
PP|AIL|Jallet|0.25|kg|1.69|0.25|6.76|true
PP|AIL|DS restauration|2.5|kg|25.0|2.5|10.0|true
PP|AIL|DS restauration|2.5|kg|25.0|2.5|10.0|true
PP|AIL|DS restauration|2.5|kg|25.0|2.5|10.0|true
PP|AIL|Cap traiteur|3.0|kg|58.5|3.0|19.5|true
PP|AIL|DS restauration|2.5|kg|25.0|2.5|10.0|true
PP|AIL|DS restauration|2.5|kg|25.0|2.5|10.0|true
PP|AIL|DS restauration|2.5|kg|25.0|2.5|10.0|true
PP|AIL|DS restauration|2.5|kg|25.0|2.5|10.0|true
PP|Asperges|Transgourmet|3.0|kg|46.1|3.0|15.3667|true
PP|Asperges|Transgourmet|3.0|kg|49.7|3.0|16.5667|true
PP|Asperges|Transgourmet|3.0|kg|46.1|3.0|15.3667|true
PP|Asperges|Transgourmet|3.0|kg|55.92|3.0|18.64|true
PP|Betterave|Jallet|2.0|kg|2.5|2.0|1.25|true
PP|Betterave|Jallet|2.0|kg|2.3|2.0|1.15|true
PP|Betterave|Jallet|4.0|kg|4.6|4.0|1.15|true
PP|Betterave|Jallet|4.0|kg|4.6|4.0|1.15|true
PP|Butternut|Jallet|2.0|kg|4.0|2.0|2.0|true
PP|Carotte|Sysco|10.0|kg|29.5|10.0|2.95|true
PP|Carotte|Jallet|20.0|kg|28.0|20.0|1.4|true
PP|Carotte|Jallet|20.0|kg|28.0|20.0|1.4|true
PP|Carotte|Jallet|20.0|kg|28.0|20.0|1.4|true
PP|Celeri remoulade|Sysco|2.1|kg|9.98|2.1|4.7524|true
PP|Celeri remoulade|Sysco|2.1|kg|9.98|2.1|4.7524|true
PP|Celeri remoulade|Sysco|2.1|kg|9.98|2.1|4.7524|true
PP|Celeri remoulade|Sysco|2.1|kg|9.98|2.1|4.7524|true
PP|Celeri remoulade|Sysco|2.1|kg|9.98|2.1|4.7524|true
PP|Celeri remoulade|Sysco|2.1|kg|9.98|2.1|4.7524|true
PP|Celeri remoulade|Jallet|2.0|kg|5.0|2.0|2.5|true
PP|Champi|Magpra|1.0|kg|9.6|1.0|9.6|true
PP|Champi|Transgourmet|1.0|kg|11.57|1.0|11.57|true
PP|Champi|Transgourmet|1.0|kg|11.65|1.0|11.65|true
PP|Champignons billes|DS restauration|10.0|kg|30.0|10.0|3.0|true
PP|Champignons billes|DS restauration|20.0|kg|60.0|20.0|3.0|true
PP|Champignons billes|DS restauration|10.0|kg|30.0|10.0|3.0|true
PP|Champignons billes|Délices des bois|20.0|kg|1590.0|20.0|79.5|true
PP|Champignons billes|Délices des bois|15.0|kg|1350.0|15.0|90.0|true
PP|Champignons billes|Délices des bois|5.0|kg|281.5|5.0|56.3|true
PP|Champignons billes|Délices des bois|1.0|kg|56.3|1.0|56.3|true
PP|Chou|Jallet|3.6|kg|10.8|3.6|3.0|true
PP|Chou|Jallet|2.25|kg|6.19|2.25|2.7511|true
PP|Chou|Jallet|6.0|kg|13.5|6.0|2.25|true
PP|Chou-fleur|DS restauration|10.0|kg|37.4|10.0|3.74|true
PP|Chou-fleur|DS restauration|2.5|kg|9.73|2.5|3.892|true
PP|cornichons|Magpra|1.0|kg|9.91|1.0|9.91|true
PP|cornichons|Magpra|2.0|kg|19.81|2.0|9.905|true
PP|cornichons|ABP|1.0|kg|12.83|1.0|12.83|true
PP|Courgette|Jallet|37.9|kg|79.59|37.9|2.1|true
PP|Courgette|Jallet|26.2|kg|55.02|26.2|2.1|true
PP|Courgette|Jallet|42.2|kg|78.07|42.2|1.85|true
PP|Courgette|Jallet|42.2|kg|78.07|42.2|1.85|true
PP|Courgette|DS restauration|2.5|kg|14.5|2.5|5.8|true
PP|Courgette|DS restauration|5.0|kg|29.0|5.0|5.8|true
PP|endive|Sysco|4.8|kg|34.42|4.8|7.1708|true
PP|endive|Sysco|4.8|kg|38.4|4.8|8.0|true
PP|endive|Sysco|9.6|kg|76.8|9.6|8.0|true
PP|Echalote|Jallet|5.0|kg|25.0|5.0|5.0|true
PP|Echalote|ABP|1.0|kg|3.59|1.0|3.59|true
PP|Echalote|ABP|1.0|kg|3.59|1.0|3.59|true
PP|Echalote|DS restauration|2.5|kg|19.0|2.5|7.6|true
PP|Echalote|DS restauration|2.5|kg|19.0|2.5|7.6|true
PP|Echalote|DS restauration|2.5|kg|19.0|2.5|7.6|true
PP|Echalote|DS restauration|2.5|kg|19.0|2.5|7.6|true
PP|Echalote|DS restauration|2.5|kg|19.0|2.5|7.6|true
PP|Epinard|DS restauration|20.0|kg|78.0|20.0|3.9|true
PP|Epinard|DS restauration|20.0|kg|78.0|20.0|3.9|true
PP|Epinard|DS restauration|10.0|kg|39.0|10.0|3.9|true
PP|Epinard|DS restauration|20.0|kg|78.0|20.0|3.9|true
PP|Epinard|DS restauration|10.0|kg|32.6|10.0|3.26|true
PP|Epinard|DS restauration|20.0|kg|78.0|20.0|3.9|true
PP|Gingembre|Jallet|0.6|kg|4.2|0.6|7.0|true
PP|Haricots|Sysco|10.0|kg|44.5|10.0|4.45|true
PP|Haricots|DS restauration|10.0|kg|37.1|10.0|3.71|true
PP|Haricots|DS restauration|10.0|kg|37.1|10.0|3.71|true
PP|Haricots|DS restauration|10.0|kg|37.1|10.0|3.71|true
PP|Lentilles|Ribeyron|10.0|kg|89.4|10.0|8.94|true
PP|Lentilles|Ribeyron|10.0|kg|89.4|10.0|8.94|true
PP|Lentilles|Ribeyron|150.0|kg|223.5|150.0|1.49|true
PP|Lentilles|Ribeyron|150.0|kg|223.5|150.0|1.49|true
PP|Lentilles|Ribeyron|150.0|kg|223.5|150.0|1.49|true
PP|Macédoine|DS restauration|10.0|kg|22.0|10.0|2.2|true
PP|Macédoine|DS restauration|10.0|kg|22.0|10.0|2.2|true
PP|Macédoine|DS restauration|20.0|kg|44.0|20.0|2.2|true
PP|Macédoine|DS restauration|10.0|kg|22.0|10.0|2.2|true
PP|Macédoine|DS restauration|10.0|kg|22.0|10.0|2.2|true
PP|Macédoine|DS restauration|10.0|kg|22.0|10.0|2.2|true
PP|Macédoine|DS restauration|10.0|kg|22.0|10.0|2.2|true
PP|Maïs|Magpra|2.0|kg|4.13|2.0|2.065|true
PP|Maïs|France frais|1.5|kg|7.53|1.5|5.02|true
PP|Maïs|France frais|1.0|kg|5.02|1.0|5.02|true
PP|Maïs|Transgourmet|1.0|kg|5.81|1.0|5.81|true
PP|Maïs|Transgourmet|1.0|kg|5.81|1.0|5.81|true
PP|Maïs|Transgourmet|1.0|kg|5.81|1.0|5.81|true
PP|Maïs|Transgourmet|1.0|kg|5.81|1.0|5.81|true
PP|Maïs|Transgourmet|2.0|kg|11.61|2.0|5.805|true
PP|Mélange|Sysco|3.2|kg|97.3|3.2|30.4063|true
PP|Mélange|Sysco|3.2|kg|49.91|3.2|15.5969|true
PP|Mélange|DS restauration|5.0|kg|18.0|5.0|3.6|true
PP|Mélange|France frais|0.1|kg|26.19|0.1|261.9|true
PP|Mélange|Colin|0.8|kg|45.54|0.8|56.925|true
PP|Oignons|Jallet|5.5|kg|9.08|5.5|1.6509|true
PP|Oignons|Jallet|5.0|kg|8.25|5.0|1.65|true
PP|Oignons|Magpra|10.0|kg|17.41|10.0|1.741|true
PP|Oignons|DS restauration|10.0|kg|31.0|10.0|3.1|true
PP|Oignons|DS restauration|5.0|kg|16.25|5.0|3.25|true
PP|Oignons|DS restauration|10.0|kg|31.0|10.0|3.1|true
PP|Oignons|Transgourmet|4.2|kg|11.71|4.2|2.7881|true
PP|Oignons|Transgourmet|4.2|kg|11.71|4.2|2.7881|true
PP|Oignons|Transgourmet|8.4|kg|23.43|8.4|2.7893|true
PP|Oignons|Transgourmet|8.4|kg|23.43|8.4|2.7893|true
PP|Patate douce|Jallet|4.0|kg|15.0|4.0|3.75|true
PP|Poireaux|Magpra|20.0|kg|33.38|20.0|1.669|true
PP|Poireaux|Magpra|20.0|kg|33.38|20.0|1.669|true
PP|Poireaux|Sysco|2.6|kg|28.11|2.6|10.8115|true
PP|Poireaux|Sysco|5.2|kg|56.21|5.2|10.8096|true
PP|Poireaux|DS restauration|60.0|kg|83.4|60.0|1.39|true
PP|Poireaux|DS restauration|10.0|kg|27.1|10.0|2.71|true
PP|Poireaux|DS restauration|60.0|kg|83.4|60.0|1.39|true
PP|Poireaux|DS restauration|10.0|kg|27.1|10.0|2.71|true
PP|Poireaux|DS restauration|10.0|kg|27.1|10.0|2.71|true
PP|Poireaux|DS restauration|10.0|kg|27.1|10.0|2.71|true
PP|pois chiche|Metro|0.38|kg|1.83|0.38|4.8158|true
PP|pois chiche|Metro|6.0|kg|6.45|6.0|1.075|true
PP|Petits pois|DS restauration|10.0|kg|49.0|10.0|4.9|true
PP|Petits pois|DS restauration|5.0|kg|24.5|5.0|4.9|true
PP|Poivrons|Sysco|10.0|kg|29.5|10.0|2.95|true
PP|Poivrons|DS restauration|2.5|kg|10.18|2.5|4.072|true
PP|Poivrons|Jallet|3.5|kg|14.88|3.5|4.2514|true
PP|Poivrons|Jallet|1.3|kg|5.85|1.3|4.5|true
PP|PDT|Grelet|150.0|kg|255.0|150.0|1.7|true
PP|PDT|Grelet|100.0|kg|170.0|100.0|1.7|true
PP|PDT|Grelet|150.0|kg|255.0|150.0|1.7|true
PP|PDT|Grelet|100.0|kg|170.0|100.0|1.7|true
PP|Ratatouille|DS restauration|10.0|kg|39.0|10.0|3.9|true
PP|Ratatouille|DS restauration|5.0|kg|19.5|5.0|3.9|true
PP|Ratatouille|DS restauration|5.0|kg|19.5|5.0|3.9|true
PP|Salade|Jallet|12.0|kg|11.4|12.0|0.95|true
PP|Salade|Jallet|12.0|kg|11.4|12.0|0.95|true
PP|Tomates|Jallet|41.0|kg|102.5|41.0|2.5|true
PP|Tomates|Jallet|42.4|kg|106.0|42.4|2.5|true
PP|Tomates|Jallet|7.0|kg|15.4|7.0|2.2|true
PP|Tomates|Jallet|30.0|kg|60.0|30.0|2.0|true
PP|Tomates|Jallet|44.6|kg|89.2|44.6|2.0|true
PP|Tomates|Jallet|14.0|kg|30.8|14.0|2.2|true
PP|Tomates|Jallet|24.0|kg|42.0|24.0|1.75|true
PP|Tomates|Jallet|24.0|kg|48.0|24.0|2.0|true
PP|Tomates|Jallet|12.0|kg|21.0|12.0|1.75|true
PP|Tomates|Colin|2.0|kg|72.84|2.0|36.42|true
PP|Tomates|ABP|6.0|kg|40.94|6.0|6.8233|true
PP|Tomates|ABP|3.0|kg|20.47|3.0|6.8233|true
PP|Tomates|ABP|3.0|kg|20.47|3.0|6.8233|true
PP|Tomates|ABP|3.0|kg|20.47|3.0|6.8233|true
PP|Julienne|DS restauration|10.0|kg|28.0|10.0|2.8|true
PP|Julienne|DS restauration|10.0|kg|28.0|10.0|2.8|true
PP|Bar|DS restauration|5.0|kg|94.5|5.0|18.9|true
PP|Bonite|Sysco|3.0|kg|47.1|3.0|15.7|true
PP|Cabillaud|Sysco|5.0|kg|85.4|5.0|17.08|true
PP|Cabillaud|Sysco|10.0|kg|169.8|10.0|16.98|true
PP|Cabillaud|Sysco|10.0|kg|170.8|10.0|17.08|true
PP|Cabillaud|Sysco|5.0|kg|85.4|5.0|17.08|true
PP|Cabillaud|Sysco|10.0|kg|170.0|10.0|17.0|true
PP|Cabillaud|Sysco|10.0|kg|170.8|10.0|17.08|true
PP|Cabillaud|Sysco|15.0|kg|297.75|15.0|19.85|true
PP|Cabillaud|DS restauration|5.0|kg|77.5|5.0|15.5|true
PP|Cabillaud|DS restauration|5.0|kg|77.5|5.0|15.5|true
PP|Cabillaud|Sysco|10.0|kg|170.8|10.0|17.08|true
PP|Cabillaud|DS restauration|5.0|kg|77.5|5.0|15.5|true
PP|Cabillaud|DS restauration|10.0|kg|155.0|10.0|15.5|true
PP|Cabillaud|DS restauration|10.0|kg|155.0|10.0|15.5|true
PP|Cabillaud|DS restauration|5.0|kg|77.5|5.0|15.5|true
PP|Cabillaud|DS restauration|5.0|kg|77.5|5.0|15.5|true
PP|Cabillaud|DS restauration|5.0|kg|77.5|5.0|15.5|true
PP|Crevettes|DS restauration|4.5|kg|84.29|4.5|18.7311|true
PP|Crevettes|DS restauration|2.0|kg|36.72|2.0|18.36|true
PP|Crevettes|DS restauration|2.25|kg|42.14|2.25|18.7289|true
PP|Crevettes|DS restauration|2.0|kg|36.72|2.0|18.36|true
PP|Crevettes|DS restauration|10.0|kg|181.3|10.0|18.13|true
PP|Crevettes|DS restauration|2.25|kg|42.14|2.25|18.7289|true
PP|Crevettes|DS restauration|2.25|kg|42.14|2.25|18.7289|true
PP|Crevettes|DS restauration|2.25|kg|42.14|2.25|18.7289|true
PP|Ecrevisse|DS restauration|8.0|kg|164.2|8.0|20.525|true
PP|Ecrevisse|DS restauration|8.0|kg|164.2|8.0|20.525|true
PP|Ecrevisse|DS restauration|8.0|kg|164.2|8.0|20.525|true
PP|Ecrevisse|DS restauration|6.4|kg|131.36|6.4|20.525|true
PP|Eglefin|DS restauration|5.0|kg|69.5|5.0|13.9|true
PP|Eglefin|DS restauration|5.0|kg|69.5|5.0|13.9|true
PP|Eglefin|DS restauration|5.0|kg|69.5|5.0|13.9|true
PP|Fletan|Coboma|4.4|kg|84.92|4.4|19.3|true
PP|Gambas|DS restauration|1.6|kg|24.0|1.6|15.0|true
PP|Gambas|DS restauration|0.8|kg|10.8|0.8|13.5|true
PP|Gambas|DS restauration|0.8|kg|10.8|0.8|13.5|true
PP|Gambas|DS restauration|0.8|kg|12.0|0.8|15.0|true
PP|Gambas|DS restauration|0.8|kg|12.0|0.8|15.0|true
PP|Gambas|DS restauration|0.8|kg|12.0|0.8|15.0|true
PP|Gambas|DS restauration|0.8|kg|12.0|0.8|15.0|true
PP|Gambas|DS restauration|1.6|kg|24.0|1.6|15.0|true
PP|Gambas|DS restauration|0.8|kg|12.0|0.8|15.0|true
PP|Gambas|DS restauration|0.8|kg|12.0|0.8|15.0|true
PP|Lieu|Coboma|2.0|kg|33.8|2.0|16.9|true
PP|Lieu|Coboma|3.0|kg|50.7|3.0|16.9|true
PP|Limande|DS restauration|3.0|kg|37.2|3.0|12.4|true
PP|Lotte|Sysco|6.4|kg|217.6|6.4|34.0|true
PP|Lotte|Sysco|3.11|kg|105.74|3.11|34.0|true
PP|Lotte|Sysco|5.112|kg|173.81|5.112|34.0004|true
PP|Lotte|Coboma|24.2|kg|556.6|24.2|23.0|true
PP|Loup|DS restauration|5.0|kg|69.5|5.0|13.9|true
PP|Loup|DS restauration|5.0|kg|69.5|5.0|13.9|true
PP|Loup|DS restauration|5.0|kg|69.5|5.0|13.9|true
PP|Loup|DS restauration|5.0|kg|69.5|5.0|13.9|true
PP|Merlan|Metro|2.01|kg|24.1|2.01|11.99|true
PP|Merlan|Metro|1.996|kg|23.93|1.996|11.989|true
PP|Merlan|Metro|2.05|kg|24.58|2.05|11.9902|true
PP|Merlan|Metro|2.086|kg|25.01|2.086|11.9895|true
PP|Merlan|Metro|2.038|kg|24.44|2.038|11.9921|true
PP|Merlan|Metro|2.03|kg|24.34|2.03|11.9901|true
PP|Merlan|Metro|4.0|kg|59.96|4.0|14.99|true
PP|Merlu|DS restauration|6.0|kg|65.4|6.0|10.9|true
PP|Merlu|DS restauration|15.0|kg|163.5|15.0|10.9|true
PP|Merlu|DS restauration|3.0|kg|32.7|3.0|10.9|true
PP|Merlu|DS restauration|3.0|kg|32.7|3.0|10.9|true
PP|Moule|Sysco|6.0|kg|22.8|6.0|3.8|true
PP|Moule|Sysco|6.0|kg|22.8|6.0|3.8|true
PP|Moule|Sysco|6.0|kg|22.8|6.0|3.8|true
PP|Moule|DS restauration|6.0|kg|37.2|6.0|6.2|true
PP|Moule|DS restauration|3.0|kg|18.6|3.0|6.2|true
PP|Quenelle|Sysco|1.92|kg|23.0|1.92|11.9792|true
PP|Quenelle|Sysco|1.92|kg|23.0|1.92|11.9792|true
PP|Quenelle|Sysco|1.92|kg|24.5|1.92|12.7604|true
PP|Quenelle|Sysco|1.92|kg|23.0|1.92|11.9792|true
PP|Quenelle|DS restauration|1.8|kg|16.02|1.8|8.9|true
PP|Quenelle|DS restauration|3.6|kg|32.04|3.6|8.9|true
PP|Quenelle|DS restauration|8.0|kg|55.2|8.0|6.9|true
PP|Quenelle|DS restauration|8.0|kg|55.2|8.0|6.9|true
PP|Quenelle|DS restauration|8.0|kg|55.2|8.0|6.9|true
PP|Saumon|SAS frais livré|1.364|kg|50.33|1.364|36.8988|true
PP|Saumon|SAS frais livré|1.072|kg|39.56|1.072|36.903|true
PP|Saumon|SAS frais livré|1.694|kg|62.51|1.694|36.9008|true
PP|Saumon|Sysco|1.758|kg|69.97|1.758|39.8009|true
PP|Saumon|Sysco|1.568|kg|62.41|1.568|39.8023|true
PP|Saumon|Sysco|1.516|kg|60.34|1.516|39.8021|true
PP|Saumon|Sysco|1.758|kg|69.97|1.758|39.8009|true
PP|Saumon|SAS frais livré|1.318|kg|27.41|1.318|20.7967|true
PP|Saumon|SAS frais livré|1.622|kg|33.74|1.622|20.8015|true
PP|Saumon|SAS frais livré|1.01|kg|21.01|1.01|20.802|true
PP|Saumon|DS restauration|5.0|kg|69.5|5.0|13.9|true
PP|Saumon|Coboma|103.4|kg|1954.26|103.4|18.9|true
PP|Saumon|Coboma|115.8|kg|1655.94|115.8|14.3|true
PP|Sébaste|Coboma|4.0|kg|58.0|4.0|14.5|true
PP|Sébaste|Coboma|4.0|kg|66.0|4.0|16.5|true
PP|Sole|Sysco|12.0|kg|189.6|12.0|15.8|true
PP|Sole|Sysco|2.0|kg|31.6|2.0|15.8|true
PP|Sole|Sysco|4.0|kg|46.4|4.0|11.6|true
PP|Sole|Sysco|2.0|kg|23.2|2.0|11.6|true
PP|Sole|Sysco|12.0|kg|129.6|12.0|10.8|true
PP|Sole|DS restauration|12.0|kg|114.0|12.0|9.5|true
PP|St jacques|Sysco|3.0|kg|113.7|3.0|37.9|true
PP|St jacques|Sysco|2.0|kg|75.8|2.0|37.9|true
PP|St jacques|DS restauration|10.0|kg|439.3|10.0|43.93|true
PP|Surimi|DS restauration|4.0|kg|37.32|4.0|9.33|true
PP|Surimi|DS restauration|2.0|kg|9.8|2.0|4.9|true
PP|Surimi|DS restauration|2.0|kg|9.8|2.0|4.9|true
PP|Thon|DS restauration|13.2|kg|170.28|13.2|12.9|true
PP|Thon|DS restauration|11.35|kg|146.42|11.35|12.9004|true
PP|Thon|DS restauration|12.0|kg|154.8|12.0|12.9|true
PP|Thon|Sysco|4.54|kg|79.45|4.54|17.5|true
PP|Thon|Sysco|2.42|kg|31.22|2.42|12.9008|true
PP|Thon|DS restauration|3.0|kg|41.7|3.0|13.9|true
PP|Thon|DS restauration|7.2|kg|51.6|7.2|7.1667|true
PP|Thon|DS restauration|7.2|kg|51.6|7.2|7.1667|true
PP|Cantal|Sysco|5.0|kg|50.5|5.0|10.1|true
PP|Cantal|Sysco|5.0|kg|50.5|5.0|10.1|true
PP|Cantal|France frais|2.0|kg|22.42|2.0|11.21|true
PP|Cantal|France frais|2.0|kg|22.42|2.0|11.21|true
PP|Cantal|Sysco|5.0|kg|50.5|5.0|10.1|true
PP|Cantal|Sysco|5.0|kg|50.5|5.0|10.1|true
PP|Cantal|Sysco|5.0|kg|50.5|5.0|10.1|true
PP|Cantal|Sysco|5.0|kg|50.5|5.0|10.1|true
PP|Cantal|ABP|10.0|kg|111.26|10.0|11.126|true
PP|Cantal|ABP|10.0|kg|111.26|10.0|11.126|true
PP|Cantal|ABP|10.0|kg|111.26|10.0|11.126|true
PP|Cantal|Sysco|2.5|kg|25.25|2.5|10.1|true
PP|Cantal|Sysco|5.0|kg|50.5|5.0|10.1|true
PP|Cantal|Transgourmet|2.0|kg|26.97|2.0|13.485|true
PP|Cantal|Transgourmet|4.0|kg|53.94|4.0|13.485|true
PP|Cantal|Transgourmet|2.0|kg|26.97|2.0|13.485|true
PP|Mozza|Sysco|10.0|kg|68.8|10.0|6.88|true
PP|Mozza|Sysco|5.0|kg|34.4|5.0|6.88|true
PP|Mozza|Sysco|10.0|kg|68.8|10.0|6.88|true
PP|Mozza|Sysco|5.0|kg|34.4|5.0|6.88|true
PP|Mozza|Sysco|5.0|kg|34.4|5.0|6.88|true
PP|Mozza|Sysco|5.0|kg|34.4|5.0|6.88|true
PP|Mozza|DS restauration|2.0|kg|13.0|2.0|6.5|true
PP|Mozza|DS restauration|2.0|kg|13.0|2.0|6.5|true
PP|Mozza|Sysco|10.0|kg|68.8|10.0|6.88|true
PP|Mozza|Sysco|5.0|kg|34.4|5.0|6.88|true
PP|Mozza|Sysco|5.0|kg|34.4|5.0|6.88|true
PP|Mozza|Sysco|5.0|kg|34.4|5.0|6.88|true
PP|Mozza|DS restauration|2.5|kg|19.75|2.5|7.9|true
PP|Mozza|DS restauration|2.5|kg|19.75|2.5|7.9|true
PP|Mozza|DS restauration|2.5|kg|19.75|2.5|7.9|true
PP|Mozza|DS restauration|4.0|kg|26.0|4.0|6.5|true
PP|From. blanc|Sysco|5.0|kg|15.55|5.0|3.11|true
PP|From. blanc|Sysco|5.0|kg|15.55|5.0|3.11|true
PP|From. blanc|Sysco|5.0|kg|15.55|5.0|3.11|true
PP|From. blanc|Sysco|5.0|kg|15.55|5.0|3.11|true
PP|From. blanc|Sysco|5.0|kg|15.55|5.0|3.11|true
PP|From. blanc|Transgourmet|5.0|kg|15.87|5.0|3.174|true
PP|From. blanc|Transgourmet|30.0|kg|114.0|30.0|3.8|true
PP|From. blanc|Transgourmet|10.0|kg|38.0|10.0|3.8|true
PP|From. blanc|Transgourmet|25.0|kg|79.33|25.0|3.1732|true
PP|From. blanc|Transgourmet|25.0|kg|95.0|25.0|3.8|true
PP|From. blanc|Transgourmet|30.0|kg|114.0|30.0|3.8|true
PP|Grana padano|Sysco|1.0|kg|20.62|1.0|20.62|true
PP|Grana padano|Sysco|1.0|kg|20.62|1.0|20.62|true
PP|Grana padano|Sysco|1.0|kg|20.62|1.0|20.62|true
PP|Grana padano|ABP|1.0|kg|17.7|1.0|17.7|true
PP|Grana padano|ABP|0.5|kg|8.85|0.5|17.7|true
PP|Grana padano|ABP|1.0|kg|17.7|1.0|17.7|true
PP|Grana padano|ABP|1.0|kg|17.7|1.0|17.7|true
PP|Grana padano|Sysco|1.0|kg|20.62|1.0|20.62|true
PP|Grana padano|Sysco|1.0|kg|20.62|1.0|20.62|true
PP|Grana padano|Sysco|1.0|kg|20.62|1.0|20.62|true
PP|Emmental|DS restauration|2.0|kg|15.8|2.0|7.9|true
PP|Emmental|DS restauration|2.0|kg|15.8|2.0|7.9|true
PP|Emmental|DS restauration|1.0|kg|7.9|1.0|7.9|true
PP|Emmental|DS restauration|2.0|kg|15.8|2.0|7.9|true
PP|Emmental|DS restauration|2.0|kg|13.8|2.0|6.9|true
PP|Emmental|DS restauration|2.0|kg|13.8|2.0|6.9|true
PP|Emmental|DS restauration|2.0|kg|13.8|2.0|6.9|true
PP|Emmental|DS restauration|0.5|kg|4.95|0.5|9.9|true
PP|Emmental|ABP|1.0|kg|11.47|1.0|11.47|true
PP|Emmental|ABP|1.0|kg|11.47|1.0|11.47|true
PP|Emmental|DS restauration|0.5|kg|4.95|0.5|9.9|true
PP|Emmental|DS restauration|0.5|kg|4.95|0.5|9.9|true
PP|Emmental|Transgourmet|0.72|kg|11.87|0.72|16.4861|true
PP|Chèvre|DS restauration|4.0|kg|58.0|4.0|14.5|true
PP|Chèvre|DS restauration|4.0|kg|58.0|4.0|14.5|true
PP|Chèvre|DS restauration|4.0|kg|58.0|4.0|14.5|true
PP|Chèvre|DS restauration|4.0|kg|58.0|4.0|14.5|true
PP|Chèvre|Transgourmet|1.5|kg|33.53|1.5|22.3533|true
PP|Gruyère|ABP|10.0|kg|85.87|10.0|8.587|true
PP|Gruyère|ABP|6.0|kg|51.52|6.0|8.5867|true
PP|Gruyère|ABP|6.0|kg|51.52|6.0|8.5867|true
PP|Lait|GAEC fournier|1740.0|kg|1284.99|1740.0|0.7385|true
PP|Lait|France frais|30.0|kg|26.67|30.0|0.889|true
PP|Lait|France frais|6.0|kg|5.33|6.0|0.8883|true
PP|Lait|France frais|6.0|kg|5.33|6.0|0.8883|true
PP|Beurre|Sysco|100.0|kg|727.0|100.0|7.27|true
PP|Beurre|ABP|10.0|kg|98.8|10.0|9.88|true
PP|Beurre|ABP|30.0|kg|318.9|30.0|10.63|true
PP|Beurre|Sysco|10.0|kg|106.6|10.0|10.66|true
PP|Beurre|ABP|10.0|kg|94.5|10.0|9.45|true
PP|Beurre|ABP|10.0|kg|94.5|10.0|9.45|true
PP|Beurre|ABP|10.0|kg|94.5|10.0|9.45|true
PP|Beurre|Magpra|10.0|kg|89.04|10.0|8.904|true
PP|Beurre|ABP|10.0|kg|128.92|10.0|12.892|true
PP|Beurre|ABP|10.0|kg|128.92|10.0|12.892|true
PP|Beurre|ABP|10.0|kg|128.92|10.0|12.892|true
PP|Beurre|ABP|10.0|kg|99.2|10.0|9.92|true
PP|Beurre|Transgourmet|10.0|kg|105.0|10.0|10.5|true
PP|Beurre|Transgourmet|10.0|kg|99.0|10.0|9.9|true
PP|Beurre|Transgourmet|30.0|kg|298.5|30.0|9.95|true
PP|Beurre|Transgourmet|30.0|kg|298.5|30.0|9.95|true
PP|Beurre|Transgourmet|30.0|kg|298.5|30.0|9.95|true
PP|Beurre|Transgourmet|30.0|kg|298.5|30.0|9.95|true
PP|Beurre|Transgourmet|20.0|kg|170.0|20.0|8.5|true
PP|Beurre|Transgourmet|20.0|kg|190.0|20.0|9.5|true
PP|Beurre|Transgourmet|20.0|kg|190.0|20.0|9.5|true
PP|Beurre|Transgourmet|10.0|kg|98.5|10.0|9.85|true
PP|Beurre|Transgourmet|10.0|kg|98.5|10.0|9.85|true
PP|Beurre|Transgourmet|10.0|kg|98.5|10.0|9.85|true
PP|Beurre|Transgourmet|10.0|kg|98.5|10.0|9.85|true
PP|Beurre|Transgourmet|20.0|kg|188.0|20.0|9.4|true
PP|Crème|Sysco|24.0|kg|90.0|24.0|3.75|true
PP|Crème|Sysco|24.0|kg|90.0|24.0|3.75|true
PP|Crème|Sysco|36.0|kg|135.0|36.0|3.75|true
PP|Crème|Sysco|36.0|kg|135.0|36.0|3.75|true
PP|Crème|ABP|120.0|kg|426.0|120.0|3.55|true
PP|Crème|Sysco|12.0|kg|45.0|12.0|3.75|true
PP|Crème|Sysco|24.0|kg|90.0|24.0|3.75|true
PP|Crème|ABP|15.0|kg|80.28|15.0|5.352|true
PP|Basmati|France frais|5.0|kg|15.89|5.0|3.178|true
PP|Basmati|France frais|5.0|kg|15.89|5.0|3.178|true
PP|Basmati|ABP|5.0|kg|20.92|5.0|4.184|true
PP|Basmati|France frais|5.0|kg|15.89|5.0|3.178|true
PP|Basmati|France frais|5.0|kg|15.89|5.0|3.178|true
PP|Basmati|Transgourmet|5.0|kg|24.93|5.0|4.986|true
PP|Basmati|Transgourmet|5.0|kg|14.0|5.0|2.8|true
PP|Long|France frais|5.0|kg|8.67|5.0|1.734|true
PP|Long|ABP|5.0|kg|14.49|5.0|2.898|true
PP|Long|ABP|5.0|kg|14.49|5.0|2.898|true
PP|Long|ABP|5.0|kg|14.49|5.0|2.898|true
PP|Long|France frais|5.0|kg|8.67|5.0|1.734|true
PP|Long|Transgourmet|5.0|kg|11.6|5.0|2.32|true
PP|Thaï|ABP|5.0|kg|14.03|5.0|2.806|true
PP|Thaï|France frais|5.0|kg|13.91|5.0|2.782|true
PP|Thaï|Transgourmet|5.0|kg|14.67|5.0|2.934|true
PP|Lasagne|Sysco|10.0|kg|44.6|10.0|4.46|true
PP|Lasagne|Sysco|10.0|kg|44.6|10.0|4.46|true
PP|Lasagne|Sysco|10.0|kg|44.6|10.0|4.46|true
PP|Lasagne|DS restauration|10.0|kg|35.0|10.0|3.5|true
PP|Lasagne|DS restauration|10.0|kg|35.0|10.0|3.5|true
PP|Lasagne|Sysco|10.0|kg|44.6|10.0|4.46|true
PP|Lasagne|Sysco|10.0|kg|44.6|10.0|4.46|true
PP|Lasagne|DS restauration|10.0|kg|35.0|10.0|3.5|true
PP|Crozet|Metro|25.0|kg|36.41|25.0|1.4564|true
PP|Nouilles|Sysco|8.0|kg|65.0|8.0|8.125|true
PP|Nouilles|Sysco|8.0|kg|65.0|8.0|8.125|true
PP|Spaghetti|France frais|10.0|kg|31.55|10.0|3.155|true
PP|Spaghetti|France frais|10.0|kg|31.55|10.0|3.155|true
PP|Spaghetti|France frais|5.0|kg|15.78|5.0|3.156|true
PP|Spaghetti|ABP|5.0|kg|14.25|5.0|2.85|true
PP|Spaghetti|France frais|10.0|kg|31.55|10.0|3.155|true
PP|Spaghetti|France frais|10.0|kg|31.55|10.0|3.155|true
PP|Spaghetti|France frais|5.0|kg|15.78|5.0|3.156|true
PP|Spaghetti|Transgourmet|5.0|kg|19.85|5.0|3.97|true
PP|Penne|France frais|5.0|kg|16.12|5.0|3.224|true
PP|Penne|France frais|5.0|kg|16.12|5.0|3.224|true
PP|Penne|France frais|5.0|kg|16.12|5.0|3.224|true
PP|Penne|France frais|5.0|kg|16.12|5.0|3.224|true
PP|Penne|France frais|5.0|kg|16.12|5.0|3.224|true
PP|Torti|France frais|4.0|kg|19.89|4.0|4.9725|true
PP|Torti|France frais|2.0|kg|9.95|2.0|4.975|true
PP|Torti|France frais|4.0|kg|19.89|4.0|4.9725|true
PP|Torti|France frais|2.0|kg|9.95|2.0|4.975|true
PP|Torti|France frais|2.0|kg|9.95|2.0|4.975|true
PP|Fusili|France frais|5.0|kg|15.99|5.0|3.198|true
PP|Tagliatelle|ABP|18.0|kg|116.28|18.0|6.46|true
PP|Tagliatelle|ABP|18.0|kg|116.28|18.0|6.46|true
PP|Tagliatelle|ABP|12.0|kg|77.52|12.0|6.46|true
PP|Tagliatelle|ABP|18.0|kg|116.28|18.0|6.46|true
PP|Tagliatelle|Transgourmet|2.0|kg|16.12|2.0|8.06|true
PP|Cajou|Metro|1.0|kg|16.15|1.0|16.15|true
PP|Coco|France frais|1.0|kg|6.69|1.0|6.69|true
PP|Coco|France frais|1.0|kg|6.68|1.0|6.68|true
PP|Coco|France frais|1.0|kg|6.68|1.0|6.68|true
PP|Coco|ABP|1.0|kg|7.52|1.0|7.52|true
PP|Coco|ABP|1.0|kg|7.52|1.0|7.52|true
PP|Coco|France frais|1.0|kg|6.68|1.0|6.68|true
PP|Noix|France frais|3.0|kg|56.7|3.0|18.9|true
PP|Noix|ABP|1.0|kg|21.28|1.0|21.28|true
PP|Noix|ABP|1.0|kg|21.28|1.0|21.28|true
PP|Noix|France frais|1.0|kg|18.9|1.0|18.9|true
PP|Noix|France frais|3.0|kg|56.7|3.0|18.9|true
PP|Pistache|France frais|1.0|kg|51.03|1.0|51.03|true
PP|Pistache|France frais|1.0|kg|51.03|1.0|51.03|true
PP|Pistache|France frais|1.0|kg|51.03|1.0|51.03|true
PP|Pistache|France frais|1.0|kg|51.03|1.0|51.03|true
PP|Noisette|ABP|1.0|kg|14.2|1.0|14.2|true
PP|Cacahuetes|Transgourmet|1.0|kg|13.6|1.0|13.6|true
PP|Cacahuetes|Transgourmet|1.0|kg|13.6|1.0|13.6|true
PP|Cacahuetes|Transgourmet|1.0|kg|13.6|1.0|13.6|true
PP|Poivre|Cap traiteur|5.0|kg|91.8|5.0|18.36|true
PP|Poivre|Cap traiteur|4.0|kg|73.44|4.0|18.36|true
PP|Poivre|Transgourmet|1.0|kg|24.0|1.0|24.0|true
PP|Poivre|Transgourmet|1.0|kg|28.07|1.0|28.07|true
PP|Poivre|Transgourmet|1.0|kg|29.86|1.0|29.86|true
PP|Poivre|Transgourmet|1.0|kg|29.86|1.0|29.86|true
PP|Sel|Moulin de massagettes|100.0|kg|38.84|100.0|0.3884|true
PP|Sel|Moulin de massagettes|100.0|kg|38.84|100.0|0.3884|true
PP|Paprika|France frais|0.45|kg|11.56|0.45|25.6889|true
PP|Paprika|Transgourmet|0.23|kg|7.99|0.23|34.7391|true
PP|Thym|Jallet|1.0|kg|1.05|1.0|1.05|true
PP|Persil|Jallet|1.0|kg|2.5|1.0|2.5|true
PP|Persil|France frais|1.035|kg|188.55|1.035|182.1739|true
PP|Persil|DS restauration|2.0|kg|14.4|2.0|7.2|true
PP|Persil|ABP|0.5|kg|9.26|0.5|18.52|true
PP|Persil|DS restauration|2.0|kg|14.4|2.0|7.2|true
PP|Persil|DS restauration|2.0|kg|14.4|2.0|7.2|true
PP|Laurier|Jallet|1.0|kg|1.05|1.0|1.05|true
PP|Oseille|DS restauration|0.25|kg|3.59|0.25|14.36|true
PP|H.Provence|ABP|1.0|kg|7.18|1.0|7.18|true
PP|Basilic|DS restauration|0.5|kg|7.78|0.5|15.56|true
PP|Basilic|DS restauration|1.0|kg|15.56|1.0|15.56|true
PP|Estragon|Jallet|1.0|kg|1.05|1.0|1.05|true
PP|Cerfeuil|Jallet|1.0|kg|1.05|1.0|1.05|true
PP|Aneth|Jallet|1.0|kg|1.05|1.0|1.05|true
PP|Cebette|Jallet|2.0|kg|3.2|2.0|1.6|true
PP|Origan|ABP|0.75|kg|9.33|0.75|12.44|true
PP|Origan|ABP|0.75|kg|9.33|0.75|12.44|true
PP|Origan|ABP|0.35|kg|8.15|0.35|23.2857|true
PP|Vin rouge|Ronchetti|36.0|l|165.6|36.0|4.6|true
PP|Vin rouge|Ronchetti|22.5|l|135.0|22.5|6.0|true
PP|Vin blanc|Ronchetti|30.0|l|63.9|30.0|2.13|true
PP|Cognac|ABP|6.0|l|113.72|6.0|18.9533|true
PP|Porto|ABP|2.0|l|18.89|2.0|9.445|true
PP|Porto|ABP|2.0|l|18.89|2.0|9.445|true
PP|Kirsch|ABP|1.0|l|16.42|1.0|16.42|true
PP|Kirsch|ABP|1.0|l|16.42|1.0|16.42|true
PP|Vermouth|ABP|2.0|l|11.37|2.0|5.685|true
PP|Vermouth|ABP|2.0|l|11.37|2.0|5.685|true
PP|Macardan|ABP|20.0|l|135.54|20.0|6.777|true
PP|Cuisson|Cap traiteur|200.0|piece|141.3|10.0|14.13|true
PP|Barquettes|La bovida|100.0|piece|36.9|5.0|7.38|true
PP|Barquettes|La bovida|100.0|piece|174.9|5.0|34.98|true
PP|Barquettes|La bovida|120.0|piece|8.25|6.0|1.375|true
PP|Farine de blé T55|Moulin de massagettes|450.0|kg|337.5|450.0|0.75|true
PP|Farine de blé T55|ABP|50.0|kg|53.3|50.0|1.066|true
PP|Farine de blé T55|Colin|10.0|kg|97.3|10.0|9.73|true
PP|Aligot|Sysco|18.0|kg|144.72|18.0|8.04|true
PP|Aligot|Sysco|12.0|kg|96.48|12.0|8.04|true
PP|Aligot|Sysco|18.0|kg|144.72|18.0|8.04|true
PP|Aligot|Sysco|12.0|kg|96.48|12.0|8.04|true
PP|Aligot|Sysco|12.0|kg|96.48|12.0|8.04|true
PP|Aligot|Sysco|18.0|kg|144.72|18.0|8.04|true
PP|Aligot|DS restauration|12.0|kg|93.6|12.0|7.8|true
PP|Aligot|DS restauration|12.0|kg|93.6|12.0|7.8|true
PP|Aligot|DS restauration|18.0|kg|140.4|18.0|7.8|true
PP|Aligot|Sysco|18.0|kg|144.72|18.0|8.04|true
PP|Aligot|Sysco|12.0|kg|96.48|12.0|8.04|true
PP|Aligot|Sysco|12.0|kg|96.48|12.0|8.04|true
PP|Aligot|Sysco|12.0|kg|96.48|12.0|8.04|true
PP|Aligot|DS restauration|6.0|kg|46.8|6.0|7.8|true
PP|Aligot|DS restauration|6.0|kg|46.8|6.0|7.8|true
PP|Aligot|DS restauration|6.0|kg|46.8|6.0|7.8|true
PP|Aligot|DS restauration|12.0|kg|93.6|12.0|7.8|true
PP|Purée carottes CE2 B|DS restauration|10.0|kg|25.0|10.0|2.5|true
PP|Purée carottes CE2 B|DS restauration|10.0|kg|25.0|10.0|2.5|true
PP|Purée carottes CE2 B|DS restauration|10.0|kg|25.0|10.0|2.5|true
PP|Purée carottes CE2 B|DS restauration|10.0|kg|25.0|10.0|2.5|true
PP|Purée carottes CE2 B|DS restauration|10.0|kg|25.0|10.0|2.5|true
PP|Purée carottes CE2 B|DS restauration|10.0|kg|25.0|10.0|2.5|true
PP|Purée potimarron bio 2,5K|DS restauration|20.0|kg|96.0|20.0|4.8|true
PP|Purée potimarron bio 2,5K|DS restauration|10.0|kg|48.0|10.0|4.8|true
PP|Purée potimarron bio 2,5K|DS restauration|5.0|kg|19.5|5.0|3.9|true
PP|Purée potimarron bio 2,5K|DS restauration|20.0|kg|78.0|20.0|3.9|true
PP|Purée pdt|Colin|6.0|kg|151.02|6.0|25.17|true
PP|Purée pdt|Colin|24.0|kg|671.28|24.0|27.97|true
PP|Purée pdt|Colin|20.0|kg|503.4|20.0|25.17|true
PP|Purée pdt|Colin|10.0|kg|251.7|10.0|25.17|true
PP|Purée pdt|Colin|4.0|kg|100.68|4.0|25.17|true
PP|Purée pdt|Colin|20.0|kg|503.4|20.0|25.17|true
PP|Sucre glace|France frais|10.0|kg|15.67|10.0|1.567|true
PP|Sucre glace|France frais|10.0|kg|15.67|10.0|1.567|true
PP|Sucre glace|ABP|10.0|kg|16.81|10.0|1.681|true
PP|Sucre glace|ABP|10.0|kg|16.81|10.0|1.681|true
PP|Sucre glace|France frais|10.0|kg|15.67|10.0|1.567|true
PP|Sucre glace|France frais|10.0|kg|15.67|10.0|1.567|true
PP|Sucre glace|Magpra|10.0|kg|17.55|10.0|1.755|true
PP|Sucre glace|Transgourmet|10.0|kg|34.32|10.0|3.432|true
PP|Sucre semoule|ABP|25.0|kg|34.75|25.0|1.39|true
PP|Sucre semoule|France frais|20.0|kg|23.1|20.0|1.155|true
PP|Sucre semoule|France frais|20.0|kg|23.1|20.0|1.155|true
PP|Sucre semoule|France frais|20.0|kg|23.1|20.0|1.155|true
PP|Sucre semoule|Transgourmet|20.0|kg|22.76|20.0|1.138|true
PP|Sucre semoule|Transgourmet|20.0|kg|42.2|20.0|2.11|true
PP|Sucre semoule|Transgourmet|20.0|kg|41.6|20.0|2.08|true
PP|Sucre semoule|Transgourmet|20.0|kg|41.6|20.0|2.08|true
PP|Huile tournesol sye BI5L|Sysco|5.0|l|10.7|5.0|2.14|true
PP|Huile tournesol sye BI5L|Sysco|5.0|l|9.95|5.0|1.99|true
PP|Huile tournesol sye BI5L|Sysco|5.0|l|12.85|5.0|2.57|true
PP|Huile tournesol sye BI5L|Magpra|5.0|l|9.61|5.0|1.922|true
PP|Huile tournesol sye BI5L|ABP|20.0|l|44.72|20.0|2.236|true
PP|Huile tournesol sye BI5L|Sysco|5.0|l|9.95|5.0|1.99|true
PP|Huile tournesol sye BI5L|Sysco|5.0|l|9.95|5.0|1.99|true
PP|Huile tournesol sye BI5L|France frais|5.0|l|9.45|5.0|1.89|true
PP|Huile tournesol sye BI5L|France frais|5.0|l|9.45|5.0|1.89|true
PP|Huile tournesol sye BI5L|Transgourmet|5.0|l|11.1|5.0|2.22|true
PP|Huile tournesol sye BI5L|Transgourmet|5.0|l|13.25|5.0|2.65|true
PP|Huile tournesol sye BI5L|Transgourmet|5.0|l|11.3|5.0|2.26|true
PP|Huile tournesol sye BI5L|Transgourmet|5.0|l|13.25|5.0|2.65|true
PP|Huile tournesol sye BI5L|Transgourmet|5.0|l|13.25|5.0|2.65|true
PP|Huile tournesol sye BI5L|Transgourmet|20.0|l|37.8|20.0|1.89|true
PP|Huile d'olive vierge extra|Sysco|5.0|l|29.35|5.0|5.87|true
PP|Huile d'olive vierge extra|Sysco|5.0|l|38.95|5.0|7.79|true
PP|Huile d'olive vierge extra|Sysco|5.0|l|29.9|5.0|5.98|true
PP|Huile d'olive vierge extra|Sysco|10.0|l|59.8|10.0|5.98|true
PP|Huile d'olive vierge extra|Magpra|5.0|l|32.24|5.0|6.448|true
PP|Huile d'olive vierge extra|Sysco|5.0|l|29.35|5.0|5.87|true
PP|Huile d'olive vierge extra|Sysco|5.0|l|29.35|5.0|5.87|true
PP|Huile d'olive vierge extra|Sysco|5.0|l|29.35|5.0|5.87|true
PP|Huile d'olive vierge extra|Sysco|5.0|l|29.35|5.0|5.87|true
PP|Huile d'olive vierge extra|Transgourmet|20.0|l|97.0|20.0|4.85|true
PP|privilege margarine tourage pl|ABP|40.0|l|194.56|40.0|4.864|true
PP|privilege margarine tourage pl|ABP|10.0|l|48.64|10.0|4.864|true
PP|privilege margarine tourage pl|ABP|10.0|l|48.64|10.0|4.864|true
PP|privilege margarine tourage pl|ABP|20.0|l|97.28|20.0|4.864|true
PP|Huile friture|Transgourmet|5.0|l|13.25|5.0|2.65|true
PP|Huile friture|Transgourmet|5.0|l|13.25|5.0|2.65|true
PP|Huile friture|Transgourmet|5.0|l|20.11|5.0|4.022|true
PP|Morilles|ABP|13.5|kg|45.59|13.5|3.377|true
PP|Morilles|ABP|4.5|kg|15.2|4.5|3.3778|true
PP|Morilles|Colin|4.0|kg|145.64|4.0|36.41|true
PP|Morilles|Colin|1.17|kg|35.38|1.17|30.2393|true
PP|Morilles|Colin|2.0|kg|51.96|2.0|25.98|true
PP|Morilles|Colin|2.0|kg|63.28|2.0|31.64|true
PP|Morilles|Colin|2.0|kg|33.42|2.0|16.71|true
PP|Morilles|Colin|2.0|kg|84.6|2.0|42.3|true
PP|Morilles|Colin|2.0|kg|39.48|2.0|19.74|true
PP|Morilles|Colin|2.0|kg|58.7|2.0|29.35|true
PP|Morilles|Colin|0.5|kg|98.96|0.5|197.92|true
PP|Morilles|Colin|20.0|kg|159.28|20.0|7.964|true
PP|Morilles|Colin|4.0|kg|121.44|4.0|30.36|true
PP|Morilles|Colin|2.0|kg|49.1|2.0|24.55|true
PP|Morilles|Colin|2.0|kg|58.06|2.0|29.03|true
PP|Morilles|Colin|2.0|kg|58.06|2.0|29.03|true
PP|Morilles|Colin|2.0|kg|91.9|2.0|45.95|true
PP|Morilles|Colin|4.0|kg|111.08|4.0|27.77|true
PP|Morilles|Colin|2.0|kg|89.5|2.0|44.75|true
PP|Morilles|Colin|2.0|kg|105.7|2.0|52.85|true
PP|Morilles|Colin|4.0|kg|127.92|4.0|31.98|true
PP|Morilles|Colin|4.0|kg|139.16|4.0|34.79|true
PP|Morilles|Colin|12.0|kg|214.08|12.0|17.84|true
PP|Morilles|France frais|0.8|kg|24.16|0.8|30.2|true
PP|Morilles|France frais|1.6|kg|48.32|1.6|30.2|true
PP|Morilles|France frais|0.8|kg|20.61|0.8|25.7625|true
PP|Morilles|France frais|1.0|kg|21.97|1.0|21.97|true
PP|Morilles|France frais|1.0|kg|21.97|1.0|21.97|true
PP|Morilles|France frais|1.0|kg|21.97|1.0|21.97|true
PP|Morilles|France frais|5.0|kg|23.45|5.0|4.69|true
PP|Morilles|France frais|5.0|kg|23.45|5.0|4.69|true
PP|Morilles|France frais|5.0|kg|23.45|5.0|4.69|true
PP|Morilles|France frais|6.0|kg|137.75|6.0|22.9583|true
PP|Morilles|France frais|3.0|kg|41.82|3.0|13.94|true
PP|Morilles|France frais|3.0|kg|41.82|3.0|13.94|true
PP|Morilles|France frais|3.0|kg|41.82|3.0|13.94|true
PP|Morilles|Sysco|1.0|kg|8.72|1.0|8.72|true
PP|Morilles|Sysco|0.7|kg|9.9|0.7|14.1429|true
PP|Morilles|Sysco|0.7|kg|9.9|0.7|14.1429|true
PP|Morilles|Transgourmet|5.0|kg|28.0|5.0|5.6|true
PP|Morilles|Transgourmet|5.0|kg|28.0|5.0|5.6|true
PP|Morilles|Transgourmet|2.0|kg|12.36|2.0|6.18|true
PP|Morilles|Colin|4.56|kg|104.6|4.56|22.9386|true
PP|Morilles|Colin|3.04|kg|0.0|3.04|0.0|true
PP|Morilles|Colin|4.56|kg|0.0|4.56|0.0|true
PP|Morilles|Colin|4.56|kg|104.6|4.56|22.9386|true
PP|mayonnise tube175g lesieur x8|Metro|1.4|kg|7.43|1.4|5.3071|true
PP|Tartare t|ABP|1.0|kg|20.78|1.0|20.78|true
PP|Tartare t|DS restauration|3.0|kg|35.94|3.0|11.98|true
PP|Tartare t|Colin|4.0|kg|41.92|4.0|10.48|true
PP|Tartare t|ABP|5.0|kg|19.23|5.0|3.846|true
PP|Tartare t|ABP|5.0|kg|19.23|5.0|3.846|true
PP|Tartare t|ABP|1.0|kg|9.51|1.0|9.51|true
PP|Tartare t|Sysco|4.0|kg|27.16|4.0|6.79|true
PP|Tartare t|Sysco|4.0|kg|27.16|4.0|6.79|true
PP|Tartare t|Transgourmet|1.0|kg|7.8|1.0|7.8|true
PP|Tartare t|Transgourmet|1.0|kg|8.82|1.0|8.82|true
PP|Tartare t|Transgourmet|1.0|kg|18.04|1.0|18.04|true
PP|Tartare t|ABP|2.5|kg|9.63|2.5|3.852|true
PP|Tartare t|Transgourmet|2.5|kg|9.0|2.5|3.6|true
PP|Tartare t|Transgourmet|2.5|kg|9.0|2.5|3.6|true
PP|Tartare t|Sysco|6.0|kg|29.5|6.0|4.9167|true
PP|Tartare t|ABP|1.2|kg|52.81|1.2|44.0083|true
PP|Tartare t|ABP|1.2|kg|52.81|1.2|44.0083|true
PP|Tartare t|ABP|1.0|kg|38.98|1.0|38.98|true
PP|Tartare t|ABP|1.0|kg|37.31|1.0|37.31|true
PP|Tartare t|Sysco|4.0|kg|51.74|4.0|12.935|true
PP|Tartare t|Sysco|4.0|kg|51.74|4.0|12.935|true
PP|Tartare t|Sysco|4.0|kg|51.74|4.0|12.935|true
PP|Tartare t|DS restauration|4.4|kg|39.16|4.4|8.9|true
PP|Tartare t|DS restauration|2.2|kg|19.58|2.2|8.9|true
PP|Tartare t|DS restauration|4.4|kg|39.16|4.4|8.9|true
PP|Tartare t|DS restauration|2.2|kg|19.58|2.2|8.9|true
PP|Tartare t|DS restauration|2.2|kg|19.58|2.2|8.9|true
PP|Tartare t|ABP|5.0|kg|11.64|5.0|2.328|true
PP|Tartare t|ABP|5.0|kg|11.64|5.0|2.328|true
PP|Tartare t|Sysco|7.2|kg|48.96|7.2|6.8|true
PP|Tartare t|Sysco|4.8|kg|32.64|4.8|6.8|true
PP|Tartare t|Sysco|2.4|kg|16.32|2.4|6.8|true
PP|Tartare t|Sysco|9.6|kg|65.28|9.6|6.8|true
PP|Tartare t|Sysco|7.2|kg|48.96|7.2|6.8|true
PP|Tartare t|Sysco|9.6|kg|65.28|9.6|6.8|true
PP|Tartare t|Sysco|9.6|kg|65.28|9.6|6.8|true
PP|Tartare t|Sysco|4.8|kg|32.64|4.8|6.8|true
PP|Tartare t|Sysco|10.4|kg|79.56|10.4|7.65|true
PP|Tartare t|Sysco|5.2|kg|39.78|5.2|7.65|true
PP|Tartare t|Sysco|5.2|kg|39.78|5.2|7.65|true
PP|Tartare t|Sysco|5.2|kg|39.78|5.2|7.65|true
PP|Tartare t|Sysco|7.8|kg|59.67|7.8|7.65|true
PP|Tartare t|Sysco|7.8|kg|59.67|7.8|7.65|true
PP|Tartare t|Sysco|5.2|kg|39.78|5.2|7.65|true
PP|Tartare t|Sysco|5.2|kg|39.78|5.2|7.65|true
PP|Tartare t|DS restauration|1.5|kg|10.35|1.5|6.9|true
PP|Tartare t|Sysco|9.0|kg|60.57|9.0|6.73|true
PP|Tartare t|Sysco|12.0|kg|126.96|12.0|10.58|true
PP|Tartare t|Sysco|9.0|kg|95.22|9.0|10.58|true
PP|Tartare t|Sysco|6.0|kg|63.48|6.0|10.58|true
PP|Tartare t|Sysco|6.0|kg|63.48|6.0|10.58|true
PP|Tartare t|Sysco|6.0|kg|63.48|6.0|10.58|true
PP|Tartare t|Sysco|6.0|kg|63.48|6.0|10.58|true
PP|Tartare t|Sysco|9.0|kg|95.22|9.0|10.58|true
PP|Tartare t|Sysco|9.0|kg|95.22|9.0|10.58|true
PP|Tartare t|Sysco|9.0|kg|95.22|9.0|10.58|true
PP|Tartare t|ABP|12.0|kg|18.31|12.0|1.5258|true
PP|Tartare t|ABP|10.0|kg|94.98|10.0|9.498|true
PP|Tartare t|ABP|10.0|kg|92.24|10.0|9.224|true
PP|Tartare t|ABP|10.0|kg|92.24|10.0|9.224|true
PP|Tartare t|Transgourmet|4.5|kg|70.54|4.5|15.6756|true
PP|Tartare t|Cap traiteur|10.0|kg|97.5|10.0|9.75|true
PP|Tartare t|Cap traiteur|1.0|kg|17.9|1.0|17.9|true
PP|Tartare t|Cap traiteur|2.0|kg|35.8|2.0|17.9|true
PP|Tartare t|Cap traiteur|10.0|kg|74.4|10.0|7.44|true
PP|Tartare t|Cap traiteur|15.0|kg|111.6|15.0|7.44|true
PP|Tartare t|Cap traiteur|3.0|kg|73.14|3.0|24.38|true
PP|Tartare t|Cap traiteur|12.0|kg|216.6|12.0|18.05|true
PP|Tartare t|Cap traiteur|12.0|kg|216.6|12.0|18.05|true
PP|Tartare t|ABP|28.0|kg|99.6|28.0|3.5571|true
PP|Tartare t|ABP|14.0|kg|49.8|14.0|3.5571|true
PP|Tartare t|ABP|42.0|kg|149.39|42.0|3.5569|true
PP|Tartare t|ABP|28.0|kg|99.6|28.0|3.5571|true
PP|Tartare t|ABP|5.0|kg|90.79|5.0|18.158|true
PP|Tartare t|ABP|5.0|kg|106.4|5.0|21.28|true
PP|Tartare t|ABP|5.0|kg|90.79|5.0|18.158|true
PP|Tartare t|ABP|5.0|kg|90.79|5.0|18.158|true
PP|Tartare t|ABP|5.0|kg|90.79|5.0|18.158|true
PP|Porc carcasse|Cantal salaisons|95.258|kg|294.35|95.258|3.09|true
PP|Porc carcasse|Cantal salaisons|99.645|kg|307.9|99.645|3.09|true
PP|Porc carcasse|Cantal salaisons|99.645|kg|307.9|99.645|3.09|true
PP|Porc carcasse|Cantal salaisons|196.171|kg|598.32|196.171|3.05|true
PP|Porc carcasse|Cantal salaisons|95.843|kg|292.32|95.843|3.05|true
PP|Porc carcasse|Cantal salaisons|100.718|kg|307.19|100.718|3.05|true
PP|Porc carcasse|Cantal salaisons|95.55|kg|303.85|95.55|3.18|true
PP|Porc carcasse|Cantal salaisons|95.435|kg|303.54|95.435|3.1806|true
PP|Porc carcasse|Cantal salaisons|195.0|kg|614.25|195.0|3.15|true
PP|Porc carcasse|Cantal salaisons|197.535|kg|622.24|197.535|3.15|true
PP|Porc carcasse|Cantal salaisons|106.763|kg|325.63|106.763|3.05|true
PP|Sang|Cantal salaisons|12.0|kg|17.4|12.0|1.45|true
PP|Sang|Cantal salaisons|12.0|kg|17.4|12.0|1.45|true
PP|Sang|Cantal salaisons|15.0|kg|21.75|15.0|1.45|true
PP|Chorizo|Sysco|1.0|kg|7.52|1.0|7.52|true
PP|Chorizo|Sysco|1.0|kg|11.4|1.0|11.4|true
PP|Chorizo|Sysco|0.5|kg|5.7|0.5|11.4|true
PP|Chorizo|Sysco|1.0|kg|11.4|1.0|11.4|true
PP|Chorizo|Sysco|1.0|kg|11.4|1.0|11.4|true
PP|Chorizo|DS restauration|0.5|kg|5.5|0.5|11.0|true
PP|Chorizo|DS restauration|0.5|kg|5.5|0.5|11.0|true
PP|morceaux|Limoujoux|5.0|kg|29.75|5.0|5.95|true
PP|morceaux|Limoujoux|43.42|kg|121.58|43.42|2.8001|true
PP|morceaux|Limoujoux|80.46|kg|225.29|80.46|2.8|true
PP|morceaux|Cantal salaisons|10.1|kg|14.14|10.1|1.4|true
PP|morceaux|Limoujoux|14.21|kg|34.1|14.21|2.3997|true
PP|morceaux|Limoujoux|11.86|kg|28.46|11.86|2.3997|true
PP|morceaux|Cantal salaisons|9.35|kg|62.46|9.35|6.6802|true
PP|morceaux|Cantal salaisons|10.45|kg|50.16|10.45|4.8|true
PP|morceaux|Cantal salaisons|6.45|kg|30.06|6.45|4.6605|true
PP|morceaux|Cantal salaisons|8.4|kg|39.06|8.4|4.65|true
PP|morceaux|Cantal salaisons|8.95|kg|41.62|8.95|4.6503|true
PP|morceaux|Cantal salaisons|1.35|kg|13.43|1.35|9.9481|true
PP|morceaux|Cantal salaisons|14.1|kg|140.3|14.1|9.9504|true
PP|morceaux|Cantal salaisons|6.5|kg|64.68|6.5|9.9508|true
PP|morceaux|Cantal salaisons|1.5|kg|14.93|1.5|9.9533|true
PP|morceaux|Cantal salaisons|7.2|kg|71.78|7.2|9.9694|true
PP|morceaux|Limoujoux|7.48|kg|12.72|7.48|1.7005|true
PP|morceaux|Limoujoux|7.48|kg|12.72|7.48|1.7005|true
PP|morceaux|Limoujoux|33.23|kg|94.71|33.23|2.8501|true
PP|morceaux|Limoujoux|19.0|kg|61.75|19.0|3.25|true
PP|morceaux|Limoujoux|19.0|kg|61.75|19.0|3.25|true
PP|morceaux|Cantal salaisons|223.8|kg|1065.29|223.8|4.76|true
PP|morceaux|Cantal salaisons|65.4|kg|311.3|65.4|4.7599|true
PP|morceaux|Cantal salaisons|143.1|kg|681.16|143.1|4.76|true
PP|morceaux|Cantal salaisons|173.4|kg|825.38|173.4|4.76|true
PP|morceaux|Cantal salaisons|205.3|kg|977.23|205.3|4.76|true
PP|morceaux|Limoujoux|8.24|kg|37.9|8.24|4.5995|true
PP|morceaux|Limoujoux|12.12|kg|55.75|12.12|4.5998|true
PP|morceaux|Limoujoux|9.44|kg|43.42|9.44|4.5996|true
PP|morceaux|Limoujoux|15.24|kg|70.1|15.24|4.5997|true
PP|morceaux|Limoujoux|21.21|kg|88.02|21.21|4.1499|true
PP|morceaux|Limoujoux|20.16|kg|83.66|20.16|4.1498|true
PP|morceaux|Limoujoux|30.86|kg|128.07|30.86|4.15|true
PP|morceaux|Limoujoux|28.5|kg|118.28|28.5|4.1502|true
PP|morceaux|Limoujoux|28.5|kg|118.28|28.5|4.1502|true
PP|morceaux|Cantal salaisons|105.3|kg|490.7|105.3|4.66|true
PP|morceaux|Cantal salaisons|68.9|kg|321.07|68.9|4.6599|true
PP|morceaux|Cantal salaisons|71.12|kg|331.42|71.12|4.66|true
PP|morceaux|Cantal salaisons|109.3|kg|509.34|109.3|4.66|true
PP|morceaux|Cantal salaisons|93.5|kg|435.71|93.5|4.66|true
PP|morceaux|Limoujoux|103.4|kg|610.06|103.4|5.9|true
PP|morceaux|Limoujoux|62.7|kg|369.93|62.7|5.9|true
PP|morceaux|Limoujoux|114.7|kg|676.73|114.7|5.9|true
PP|morceaux|Limoujoux|4.58|kg|13.28|4.58|2.8996|true
PP|morceaux|Cantal salaisons|60.0|kg|174.0|60.0|2.9|true
PP|morceaux|Cantal salaisons|114.0|kg|125.4|114.0|1.1|true
PP|morceaux|Cantal salaisons|110.1|kg|121.11|110.1|1.1|true
PP|morceaux|Cantal salaisons|115.0|kg|126.5|115.0|1.1|true
PP|morceaux|Cantal salaisons|162.05|kg|178.26|162.05|1.1|true
PP|morceaux|Scavi|250.0|kg|200.0|250.0|0.8|true
PP|morceaux|Scavi|510.38|kg|408.3|510.38|0.8|true
PP|morceaux|Limoujoux|122.19|kg|122.19|122.19|1.0|true
PP|morceaux|Limoujoux|35.82|kg|35.82|35.82|1.0|true
PP|morceaux|Limoujoux|94.48|kg|94.48|94.48|1.0|true
PP|morceaux|Limoujoux|40.0|kg|40.0|40.0|1.0|true
PP|morceaux|Limoujoux|50.98|kg|50.98|50.98|1.0|true
PP|morceaux|Limoujoux|151.1|kg|151.1|151.1|1.0|true
PP|morceaux|Limoujoux|141.14|kg|691.59|141.14|4.9|true
PP|morceaux|Limoujoux|48.38|kg|237.06|48.38|4.9|true
PP|morceaux|Limoujoux|44.14|kg|319.57|44.14|7.2399|true
PP|morceaux|Limoujoux|57.3|kg|335.21|57.3|5.8501|true
PP|morceaux|Limoujoux|68.64|kg|473.62|68.64|6.9001|true
PP|morceaux|Limoujoux|72.0|kg|82.8|72.0|1.15|true
PP|morceaux|Limoujoux|82.5|kg|94.88|82.5|1.1501|true
PP|morceaux|Limoujoux|97.5|kg|112.13|97.5|1.1501|true
PP|morceaux|Limoujoux|88.0|kg|101.2|88.0|1.15|true
PP|morceaux|Limoujoux|88.0|kg|101.2|88.0|1.15|true
PP|AV CAPA|Tradival|82.24|kg|814.17|82.24|9.8999|true
PP|AV CAPA|Tradival|92.44|kg|915.15|92.44|9.8999|true
PP|Filet|Tradival|4.34|kg|119.78|4.34|27.5991|true
PP|Noix de joue|Tradival|21.2|kg|275.6|21.2|13.0|true
PP|Paleron|Tradival|24.26|kg|312.96|24.26|12.9002|true
PP|Paleron|Tradival|20.08|kg|238.95|20.08|11.8999|true
PP|Rond gite|Tradival|86.34|kg|1174.22|86.34|13.6|true
PP|Rond gite|Metro|2.475|kg|45.76|2.475|18.4889|true
PP|Rond gite|Metro|1.965|kg|36.33|1.965|18.4885|true
PP|Rond gite|Metro|2.94|kg|54.36|2.94|18.4898|true
PP|Rond gite|Metro|2.56|kg|47.33|2.56|18.4883|true
PP|Langue|DS restauration|6.821|kg|121.07|6.821|17.7496|true
PP|Egrene|Sysco|6.0|kg|70.26|6.0|11.71|true
PP|Egrene|Sysco|24.0|kg|281.04|24.0|11.71|true
PP|Egrene|Sysco|6.0|kg|70.26|6.0|11.71|true
PP|Egrene|DS restauration|12.0|kg|142.8|12.0|11.9|true
PP|Egrene|DS restauration|12.0|kg|142.8|12.0|11.9|true
PP|Egrene|Sysco|12.0|kg|140.52|12.0|11.71|true
PP|Veau|Tradival|171.3|kg|1525.09|171.3|8.903|true
PP|Veau|DS restauration|217.22|kg|3762.25|217.22|17.32|true
PP|Veau|DS restauration|103.56|kg|1793.0|103.56|17.3136|true
PP|cord. bleu dinde|Sysco|9.0|kg|119.0|9.0|13.2222|true
PP|cord. bleu dinde|Sysco|1.8|kg|23.8|1.8|13.2222|true
PP|cord. bleu dinde|Sysco|9.0|kg|119.0|9.0|13.2222|true
PP|cord. bleu dinde|Sysco|3.6|kg|47.6|3.6|13.2222|true
PP|Cord. bleu poulet|DS restauration|7.2|kg|92.88|7.2|12.9|true
PP|Cord. bleu poulet|DS restauration|7.2|kg|92.88|7.2|12.9|true
PP|Cord. bleu poulet|DS restauration|7.2|kg|92.88|7.2|12.9|true
PP|Cord. bleu poulet|DS restauration|3.6|kg|46.44|3.6|12.9|true
PP|coq au vin|Sysco|5.67|kg|55.85|5.67|9.8501|true
PP|coq au vin|Sysco|5.67|kg|55.85|5.67|9.8501|true
PP|coq au vin|Sysco|5.67|kg|55.85|5.67|9.8501|true
PP|Gésier|DS restauration|2.0|kg|15.8|2.0|7.9|true
PP|Canard|DS restauration|4.0|kg|67.6|4.0|16.9|true
PP|Canard|DS restauration|4.0|kg|67.6|4.0|16.9|true
PP|Canard|DS restauration|6.4|kg|86.4|6.4|13.5|true
PP|Canard|DS restauration|12.8|kg|172.8|12.8|13.5|true
PP|Poulet|Allier volailles|81.14|kg|700.24|81.14|8.63|true
PP|Poulet|Allier volailles|20.18|kg|174.15|20.18|8.6298|true
PP|Poulet|Allier volailles|60.14|kg|519.01|60.14|8.63|true
PP|Poulet|Allier volailles|30.08|kg|259.59|30.08|8.63|true
PP|Poulet|Allier volailles|30.16|kg|260.28|30.16|8.63|true
PP|Poulet|Allier volailles|80.18|kg|691.95|80.18|8.63|true
PP|Poulet|Allier volailles|80.34|kg|693.33|80.34|8.6299|true
PP|Poulet|Allier volailles|14.38|kg|145.96|14.38|10.1502|true
PP|Dinde|Allier volailles|80.18|kg|691.96|80.18|8.6301|true
PP|Oeuf solide|Sysco|48.0|piece|38.4|2.4|16.0|true
PP|Oeuf solide|France frais|360.0|piece|85.32|18.0|4.74|true
PP|Oeuf solide|France frais|180.0|piece|46.62|9.0|5.18|true
PP|Oeuf solide|DS restauration|96.0|piece|52.8|4.8|11.0|true
PP|Oeuf solide|DS restauration|96.0|piece|52.8|4.8|11.0|true
PP|Oeuf solide|DS restauration|96.0|piece|52.8|4.8|11.0|true
PP|Oeuf solide|DS restauration|48.0|piece|26.4|2.4|11.0|true
PP|Oeuf solide|ABP|360.0|piece|73.15|18.0|4.0639|true
PP|Oeuf solide|ABP|360.0|piece|73.15|18.0|4.0639|true
PP|Oeuf solide|ABP|360.0|piece|73.15|18.0|4.0639|true
PP|Oeuf solide|Sysco|48.0|piece|38.4|2.4|16.0|true
PP|Oeuf solide|DS restauration|48.0|piece|26.4|2.4|11.0|true
PP|Oeuf solide|DS restauration|48.0|piece|26.4|2.4|11.0|true
PP|Oeuf solide|DS restauration|48.0|piece|26.4|2.4|11.0|true
PP|Oeuf solide|DS restauration|48.0|piece|26.4|2.4|11.0|true
PP|Oeuf solide|Transgourmet|180.0|piece|44.9|9.0|4.9889|true
PP|Oeuf solide|Transgourmet|180.0|piece|44.9|9.0|4.9889|true
PP|Oeuf solide|Transgourmet|180.0|piece|44.9|9.0|4.9889|true
PP|Oeuf solide|Transgourmet|360.0|piece|84.0|18.0|4.6667|true
PP|Oeuf solide|Moy frais|0.6|piece|0.0|0.03|0.0|true
PP|Oeuf solide|France frais|0.533|piece|0.0|0.027|0.0|true
PP|Oeuf solide|ABP|0.55|piece|0.0|0.028|0.0|true
PP|Blanc|DS restauration|6.0|piece|27.6|0.3|92.0|true
PP|Blanc|DS restauration|2.0|piece|9.2|0.1|92.0|true
PP|Blanc|DS restauration|4.0|piece|18.4|0.2|92.0|true
PP|Blanc|DS restauration|2.0|piece|9.2|0.1|92.0|true
PP|Blanc|DS restauration|4.0|piece|18.4|0.2|92.0|true
PP|Blanc|ABP|2.0|piece|10.37|0.1|103.7|true
PP|Blanc|France frais|2.0|piece|9.65|0.1|96.5|true
PP|Blanc|France frais|6.0|piece|27.6|0.3|92.0|true
PP|Blanc|DS restauration|6.0|piece|27.6|0.3|92.0|true
PP|Blanc|DS restauration|2.0|piece|9.2|0.1|92.0|true
PP|Blanc|DS restauration|6.0|piece|27.6|0.3|92.0|true
PP|Blanc|DS restauration|6.0|piece|27.6|0.3|92.0|true
PP|Blanc|DS restauration|8.0|piece|36.8|0.4|92.0|true
PP|Blanc|Transgourmet|2.0|piece|15.9|0.1|159.0|true
PP|Blanc|Transgourmet|2.0|piece|15.9|0.1|159.0|true
PP|Oeuf liquide entier|Magpra|6.0|kg|35.59|6.0|5.9317|true
PP|Oeuf liquide entier|DS restauration|8.0|kg|39.2|8.0|4.9|true
PP|Oeuf liquide entier|DS restauration|8.0|kg|39.2|8.0|4.9|true
PP|Oeuf liquide entier|DS restauration|8.0|kg|39.2|8.0|4.9|true
PP|Oeuf liquide entier|DS restauration|6.0|kg|29.4|6.0|4.9|true
PP|Oeuf liquide entier|DS restauration|4.0|kg|19.6|4.0|4.9|true
PP|Oeuf liquide entier|ABP|4.0|kg|21.99|4.0|5.4975|true
PP|Oeuf liquide entier|ABP|5.0|kg|20.88|5.0|4.176|true
PP|Oeuf liquide entier|ABP|5.0|kg|20.88|5.0|4.176|true
PP|Oeuf liquide entier|ABP|4.0|kg|21.99|4.0|5.4975|true
PP|Oeuf liquide entier|France frais|2.0|kg|7.22|2.0|3.61|true
PP|Oeuf liquide entier|France frais|2.0|kg|7.22|2.0|3.61|true
PP|Oeuf liquide entier|France frais|2.0|kg|19.6|2.0|9.8|true
PP|Oeuf liquide entier|DS restauration|8.0|kg|39.2|8.0|4.9|true
PP|Oeuf liquide entier|DS restauration|8.0|kg|39.2|8.0|4.9|true
PP|Oeuf liquide entier|DS restauration|4.0|kg|19.6|4.0|4.9|true
PP|Oeuf liquide entier|DS restauration|8.0|kg|39.2|8.0|4.9|true
PP|Oeuf liquide entier|DS restauration|8.0|kg|39.2|8.0|4.9|true
PP|Oeuf liquide entier|DS restauration|8.0|kg|39.2|8.0|4.9|true
PP|Jaune|DS restauration|6.0|kg|50.4|6.0|8.4|true
PP|Jaune|DS restauration|2.0|kg|16.8|2.0|8.4|true
PP|Jaune|DS restauration|4.0|kg|33.6|4.0|8.4|true
PP|Jaune|DS restauration|2.0|kg|16.8|2.0|8.4|true
PP|Jaune|DS restauration|4.0|kg|33.6|4.0|8.4|true
PP|Jaune|DS restauration|5.0|kg|42.0|5.0|8.4|true
PP|Jaune|DS restauration|3.0|kg|25.2|3.0|8.4|true
PP|Jaune|DS restauration|2.0|kg|16.8|2.0|8.4|true
PP|Jaune|DS restauration|5.0|kg|42.0|5.0|8.4|true
PP|Jaune|DS restauration|2.0|kg|16.8|2.0|8.4|true
PP|Jaune|DS restauration|2.0|kg|16.8|2.0|8.4|true
PP|Jaune|DS restauration|4.0|kg|33.6|4.0|8.4|true
PP|Jaune|DS restauration|2.0|kg|16.8|2.0|8.4|true
PP|Jaune|Transgourmet|2.0|kg|23.32|2.0|11.66|true
PP|Jaune|Transgourmet|2.0|kg|34.96|2.0|17.48|true
PP|viennoiseries|CdP|300.0|piece|87.0|15.0|5.8|true
PP|canelé|CdP|48.0|piece|24.52|2.4|10.2167|true
PP|canelé|France frais|75.0|piece|42.3|3.75|11.28|true
PP|canelé|France frais|75.0|piece|42.3|3.75|11.28|true
PP|canelé|France frais|75.0|piece|42.3|3.75|11.28|true
PP|canelé|France frais|75.0|piece|42.3|3.75|11.28|true
PP|choc|CdP|12.0|piece|36.96|0.6|61.6|true
PP|Charlotine|CdP|12.0|piece|23.06|0.6|38.4333|true
PP|Charlotine|CdP|12.0|piece|23.06|0.6|38.4333|true
PP|Charlotine|CdP|12.0|piece|23.06|0.6|38.4333|true
PP|Charlotine|CdP|12.0|piece|25.55|0.6|42.5833|true
PP|Charlotine|CdP|12.0|piece|25.55|0.6|42.5833|true
PP|Chouquette|CdP|144.0|piece|35.76|7.2|4.9667|true
PP|Chouquette|CdP|144.0|piece|35.76|7.2|4.9667|true
PP|Crêpe|Sysco|560.0|piece|240.8|28.0|8.6|true
PP|Crêpe|Sysco|560.0|piece|302.4|28.0|10.8|true
PP|Crêpe|CdP|50.0|piece|44.5|2.5|17.8|true
PP|Crêpe|CdP|50.0|piece|44.5|2.5|17.8|true
PP|Crêpe|Sysco|560.0|piece|302.4|28.0|10.8|true
PP|Tiramisu|CdP|24.0|piece|35.8|1.2|29.8333|true
PP|Tiramisu|CdP|24.0|piece|35.8|1.2|29.8333|true
PP|Tiramisu|CdP|72.0|piece|107.39|3.6|29.8306|true
PP|Tiramisu|CdP|48.0|piece|71.6|2.4|29.8333|true
PP|Flan|CdP|4.0|piece|60.98|0.2|304.9|true
PP|Flan|CdP|36.0|piece|306.02|1.8|170.0111|true
PP|Flan|CdP|24.0|piece|204.01|1.2|170.0083|true
PP|Flan|CdP|18.0|piece|153.01|0.9|170.0111|true
PP|Flan|CdP|36.0|piece|306.02|1.8|170.0111|true
PP|Flan|CdP|36.0|piece|306.02|1.8|170.0111|true
PP|fond|CdP|192.0|piece|43.47|9.6|4.5281|true
PP|Moelleux|CdP|16.0|piece|252.77|0.8|315.9625|true
PP|Moelleux|CdP|12.0|piece|189.58|0.6|315.9667|true
PP|Moelleux|CdP|12.0|piece|252.77|0.6|421.2833|true
PP|Moelleux|CdP|8.0|piece|126.39|0.4|315.975|true
PP|tatin|CdP|6.0|piece|52.52|0.3|175.0667|true
PP|tatin|CdP|6.0|piece|52.52|0.3|175.0667|true
PP|Tartelette|CdP|96.0|piece|179.6|4.8|37.4167|true
PP|Tartelette|CdP|24.0|piece|44.9|1.2|37.4167|true
PP|Tartelette|CdP|24.0|piece|44.9|1.2|37.4167|true
PP|Tartelette|CdP|48.0|piece|89.8|2.4|37.4167|true
PP|Tartelette|CdP|72.0|piece|134.7|3.6|37.4167|true
PP|Tartelette|CdP|72.0|piece|134.7|3.6|37.4167|true
PP|Nougats|Magpra|2.0|piece|42.54|0.1|425.4|true
PP|Nougats|Magpra|2.0|piece|42.54|0.1|425.4|true
PP|Nougats|ABP|1.4|piece|32.94|0.07|470.5714|true
PP|Nougats|ABP|2.1|piece|49.41|0.105|470.5714|true
PP|Nougats|ABP|0.7|piece|16.47|0.035|470.5714|true
PP|Nougats|Transgourmet|0.7|piece|35.31|0.035|1008.8571|true
PP|Nougats|Transgourmet|0.7|piece|35.31|0.035|1008.8571|true
PP|Muffin|DS restauration|56.0|piece|59.96|2.8|21.4143|true
PP|Muffin|DS restauration|28.0|piece|29.98|1.4|21.4143|true
PP|Muffin|DS restauration|28.0|piece|29.98|1.4|21.4143|true
PP|Muffin|DS restauration|28.0|piece|29.98|1.4|21.4143|true
PP|Muffin|DS restauration|14.0|piece|14.99|0.7|21.4143|true
PP|Muffin|DS restauration|56.0|piece|59.96|2.8|21.4143|true
PP|Muffin|DS restauration|28.0|piece|29.98|1.4|21.4143|true
PP|Muffin|DS restauration|28.0|piece|29.98|1.4|21.4143|true
PP|pain|CdP|50.0|piece|22.48|2.5|8.992|true
PP|pain|CdP|300.0|piece|168.0|15.0|11.2|true
PP|pain|CdP|50.0|piece|28.0|2.5|11.2|true
PP|pain|ABP|120.0|piece|89.64|6.0|14.94|true
PP|pain|ABP|360.0|piece|268.92|18.0|14.94|true
PP|pain|ABP|300.0|piece|224.1|15.0|14.94|true
PP|pain|ABP|120.0|piece|89.64|6.0|14.94|true
PP|pain|ABP|180.0|piece|134.46|9.0|14.94|true
PP|pain|Fournil de jean|2.0|piece|1.49|0.1|14.9|true
PP|pain|Fournil de jean|2.0|piece|1.49|0.1|14.9|true
PP|pain|Fournil de jean|2.0|piece|1.49|0.1|14.9|true
PP|pain|Fournil de jean|2.0|piece|1.49|0.1|14.9|true
PP|pain|Fournil de jean|15.0|piece|7.77|0.75|10.36|true
PP|pain|Fournil de jean|15.0|piece|7.77|0.75|10.36|true
PP|pain|Fournil de jean|20.0|piece|10.36|1.0|10.36|true
PP|pain|Fournil de jean|20.0|piece|10.36|1.0|10.36|true
PP|pain|Fournil de jean|20.0|piece|10.36|1.0|10.36|true
PP|pain|Fournil de jean|10.0|piece|5.18|0.5|10.36|true
PP|pain|Fournil de jean|15.0|piece|3.63|0.75|4.84|true
PP|pain|Fournil de jean|15.0|piece|3.63|0.75|4.84|true
PP|pain|Fournil de jean|20.0|piece|4.84|1.0|4.84|true
PP|pain|Fournil de jean|20.0|piece|4.84|1.0|4.84|true
PP|pain|Fournil de jean|20.0|piece|4.84|1.0|4.84|true
PP|pain|Fournil de jean|10.0|piece|2.42|0.5|4.84|true
PP|chapelure|France frais|1.0|kg|2.33|1.0|2.33|true
PP|chapelure|France frais|1.0|kg|2.33|1.0|2.33|true
R|Julienne De Légume Sous Recette||0.0|true|false|false
R|Sauce Pizza||0.0|true|false|false
R|Sauce Pizza Sous Recette||0.0|true|false|false
R|Roux Sous Recette||0.0|true|false|false
R|Pate Feuilletés||0.0|true|false|false
R|Pate Brisée||0.0|true|false|false
R|Sauce Quiche||0.0|true|false|false
R|Pate Feuilletée||0.0|true|false|false
R|Gratin Dauphinois||0.0|true|false|false
R|Légumes Sous Recettes||0.0|true|false|false
R|Carotte Rapées Sous Recette||0.0|true|false|false
R|Salade Du Moment Sous Recette||0.0|true|false|false
R|Pate Sucrée Sous Recette||0.0|true|false|false
R|Frangipane Sous Recette||0.0|true|false|false
R|Farce À Pied Sous Recette||0.0|true|false|false
R|Sauce Ris De Veau Louche Sous Recette||0.0|true|false|false
R|Spaghetti Bolognaise Sous Recette||0.0|true|false|false
R|Purée Sous Recette||0.0|true|false|false
R|Chippolata Sous Recette||0.0|true|false|false
R|Farce À Tomate Sous Recette||0.0|true|false|false
R|Grosse Saucisse Sous Recette||0.0|true|false|false
R|Tranche De Jambon Blanc Sous Recette||0.0|true|false|false
R|Poireaux sous recette||0.0|true|false|false
R|Légumes sous recette||0.0|true|false|false
R|TPT sous recette||0.0|true|false|false
R|Sauce spaghetti sous recette||0.0|true|false|false
R|Bolognaise sous recette||0.0|true|false|false
R|jus de fruit sous recette||0.0|true|false|false
R|Carottes rapées sous recette||0.0|true|false|false
R|vinaigrette carottes rappées sous recette||0.0|true|false|false
R|mayonnaise sous recette||0.0|true|false|false
R|Vinaigrette sous recette||0.0|true|false|false
R|vinaigrette balsamique sous recette||0.0|true|false|false
R|Pate à pompe||0.0|false|false|false
R|Pate sucrée||0.0|false|false|false
R|Pate à pizza||0.0|false|false|false
R|Pate à paté croute||0.0|false|false|false
R|Roux||0.0|false|false|false
R|Sauce feuilleté bleu||0.0|false|false|false
R|Sauce saumon||0.0|false|false|false
R|Béchamel feuilleté jambon||0.0|false|false|false
R|Feuilleté écrevisse||0.0|false|false|false
R|Sauce fruits de mer||0.0|false|false|false
R|Sauce Feuilleté ris de veau||0.0|false|false|false
R|Sauce Feuilleté poulet||0.0|false|false|false
R|Sauce quiche||0.0|false|false|false
R|Sauce pizza||0.0|false|false|false
R|Sauce ris de veau Louche||0.0|false|false|false
R|Sauce Saint Jacques||0.0|false|false|false
R|brioche aux grattons||0.0|false|false|false
R|Sauce quiche (2)||0.0|false|false|false
R|Pate à croissant||0.0|false|false|false
R|Pate à paté croute **||0.0|false|false|false
R|Feuilletés 4 portions||0.0|false|false|false
R|Feuilletés 6 portions||0.0|false|false|false
R|Feuilleté 8 personnes||0.0|false|false|false
R|Quiche Lorraine||0.0|false|false|false
R|Quiche légumes||0.0|false|false|false
R|Quiche thon tomates||0.0|false|false|false
R|Quiche saumon asperges||0.0|false|false|false
R|Quiche chèvre épinard||0.0|false|false|false
R|Choux farcis||0.0|false|false|false
R|Fricassé de volaille||0.0|false|false|false
R|Gratin dauphinois||0.0|false|false|false
R|Paté pomme de terre|4 portions|0.0|false|false|false
R|Paté pomme de terre (2)|2 portions|0.0|false|false|false
R|Aligot||0.0|false|false|false
R|Purée||0.0|false|false|false
R|Tagliatelle écrevisses||0.0|false|false|false
R|Beurre escargot||0.0|false|false|false
R|Quiches||0.0|false|false|false
R|Quiche asperge / saumon||0.0|false|false|false
R|Quiche au légumes||0.0|false|false|false
R|salade poulet barquette||0.0|false|false|false
R|tarte aux myrtilles||0.0|false|false|false
R|Frangipane||0.0|false|false|false
R|Parmentier de canard Barquette||0.0|false|false|false
R|pied de cochon sous vide||0.0|false|false|false
R|Jambon cuit||0.0|false|false|false
R|Ris de veau aux morilles louche barquette||0.0|false|false|false
R|Spaghetti bolognaise Barquette||0.0|false|false|false
R|purée saucisses Barquette||0.0|false|false|false
R|tomates farcies||0.0|false|false|false
R|fromage blanc||0.0|false|false|false
R|salade de fruit||0.0|false|false|false
R|choux carottes||0.0|false|false|false
R|Lentilles||0.0|false|false|false
R|Océance||0.0|false|false|false
R|pommes de terre||0.0|false|false|false
R|poulet pâtes||0.0|false|false|false
R|riz niçois||0.0|false|false|false
R|macédoine||0.0|false|false|false
R|haricots verts||0.0|false|false|false
R|piemontaise||0.0|false|false|false
R|melon||0.0|false|false|false
R|Aligot saucisse||0.0|false|false|false
R|asperges au jambon||0.0|false|false|false
RC|Poireaux sous recette|Product|Poireaux|50.0|kg
RC|Poireaux sous recette|Product|Beurre|1.0|kg
RC|Poireaux sous recette|Product|Sel|0.5|kg
RC|Poireaux sous recette|Product|Sucre semoule|0.6|kg
RC|Légumes sous recette|Product|Julienne|5.0|kg
RC|Légumes sous recette|Product|Gruyère|1.0|kg
RC|Légumes sous recette|Product|Sel|0.03|kg
RC|Légumes sous recette|Product|Poivre|0.03|kg
RC|TPT sous recette|Product|Sucre glace|6.0|kg
RC|TPT sous recette|Product|Poudre d'amandes|4.0|kg
RC|TPT sous recette|Product|Farine de blé T55|2.0|kg
RC|TPT sous recette|Product|Levure|0.1|kg
RC|Sauce spaghetti sous recette|Product|Beurre|0.75|kg
RC|Sauce spaghetti sous recette|Product|Sel|0.03|kg
RC|Sauce spaghetti sous recette|Product|Poivre|0.005|kg
RC|Sauce spaghetti sous recette|Recipe|Sauce Pizza|4.5|kg
RC|Sauce spaghetti sous recette|Product|Tomates|0.1|kg
RC|Bolognaise sous recette|Product|Huile d'olive vierge extra|3.0|kg
RC|Bolognaise sous recette|Product|Oignons|10.0|kg
RC|Bolognaise sous recette|Product|Carotte|8.0|kg
RC|Bolognaise sous recette|Product|Égrainés de bœuf|60.0|kg
RC|Bolognaise sous recette|Product|Vin blanc|3.0|l
RC|Bolognaise sous recette|Product|Tomates|10.0|kg
RC|Bolognaise sous recette|Product|Gustoza|9.0|kg
RC|Bolognaise sous recette|Product|Veau|1.5|kg
RC|Bolognaise sous recette|Product|Sel|0.8|kg
RC|Bolognaise sous recette|Product|Poivre|0.04|kg
RC|Bolognaise sous recette|Product|Piment|0.01|kg
RC|Bolognaise sous recette|Product|choc|0.2|kg
RC|Bolognaise sous recette|Product|Persil|1.5|kg
RC|jus de fruit sous recette|Product|Framboise|1.0|kg
RC|jus de fruit sous recette|Product|Sucre semoule|0.15|kg
RC|Carottes rapées sous recette|Product|Carotte|1.3|kg
RC|Carottes rapées sous recette|Recipe|vinaigrette carottes rappées sous recette|0.25|l
RC|vinaigrette carottes rappées sous recette|Product|Huile tournesol sye BI5L|3.5|l
RC|vinaigrette carottes rappées sous recette|Product|Huile d'olive vierge extra|0.5|l
RC|vinaigrette carottes rappées sous recette|Product|Vinaigre de vin|2.2|l
RC|vinaigrette carottes rappées sous recette|Product|Vinaigre balsamique|0.6|l
RC|vinaigrette carottes rappées sous recette|Product|Moutarde|1.0|kg
RC|vinaigrette carottes rappées sous recette|Product|Persil|0.02|kg
RC|vinaigrette carottes rappées sous recette|Product|Sel|0.2|kg
RC|vinaigrette carottes rappées sous recette|Product|Poivre|0.02|kg
RC|vinaigrette carottes rappées sous recette|Product|Mayonnaise|0.3|kg
RC|vinaigrette carottes rappées sous recette|Product|Citron|0.6|kg
RC|mayonnaise sous recette|Product|Jaune|2.0|kg
RC|mayonnaise sous recette|Product|Moutarde|1.0|kg
RC|mayonnaise sous recette|Product|Sel|0.1|kg
RC|mayonnaise sous recette|Product|Poivre|0.01|kg
RC|mayonnaise sous recette|Product|Vinaigre|0.3|kg
RC|mayonnaise sous recette|Product|Huile tournesol sye BI5L|12.5|l
RC|Vinaigrette sous recette|Product|Huile tournesol sye BI5L|3.5|l
RC|Vinaigrette sous recette|Product|Huile d'olive vierge extra|0.5|l
RC|Vinaigrette sous recette|Product|Vinaigre|1.2|l
RC|Vinaigrette sous recette|Product|Vinaigre balsamique|0.4|l
RC|Vinaigrette sous recette|Product|Moutarde|1.0|kg
RC|Vinaigrette sous recette|Product|Persil|0.01|kg
RC|Vinaigrette sous recette|Product|Sel|0.1|kg
RC|Vinaigrette sous recette|Product|Poivre|0.02|kg
RC|Vinaigrette sous recette|Product|Mayonnaise|0.2|kg
RC|vinaigrette balsamique sous recette|Product|Huile tournesol sye BI5L|4.0|l
RC|vinaigrette balsamique sous recette|Product|Vinaigre balsamique|2.0|l
RC|vinaigrette balsamique sous recette|Product|Moutarde|0.4|kg
RC|vinaigrette balsamique sous recette|Product|Mayonnaise|0.15|kg
RC|vinaigrette balsamique sous recette|Product|Sel|0.07|kg
RC|vinaigrette balsamique sous recette|Product|Poivre|0.01|kg
RC|Pate à pompe|Product|Farine de blé T55|50.0|kg
RC|Pate à pompe|Product|Beurre|12.0|kg
RC|Pate à pompe|Product|privilege margarine tourage pl|6.0|kg
RC|Pate à pompe|Product|Sucre semoule|16.0|kg
RC|Pate à pompe|Product|Sel|0.3|kg
RC|Pate à pompe|Product|Huile tournesol sye BI5L|2.5|l
RC|Pate sucrée|Product|Farine de blé T55|30.0|kg
RC|Pate sucrée|Product|Beurre|15.0|kg
RC|Pate sucrée|Product|Sucre glace|14.5|kg
RC|Pate sucrée|Product|Fécule|8.0|kg
RC|Pate sucrée|Product|Poudre d'amandes|4.5|kg
RC|Pate sucrée|Product|Sel|0.2|kg
RC|Pate sucrée|Product|Oeuf solide|9.0|l
RC|Pate sucrée|Product|Vanille|0.1|kg
RC|Pate à pizza|Product|Farine de blé T55|50.0|kg
RC|Pate à pizza|Product|Sel|1.0|kg
RC|Pate à pizza|Product|Sucre semoule|2.5|kg
RC|Pate à pizza|Product|Oeuf solide|9.0|kg
RC|Pate à pizza|Product|Levure|2.5|kg
RC|Pate à pizza|Product|Lait|6.0|l
RC|Pate à pizza|Product|Huile d'olive vierge extra|1.0|l
RC|Pate à pizza|Product|Beurre|7.0|kg
RC|Pate à pizza|Product|privilege margarine tourage pl|6.0|kg
RC|Pate à paté croute|Product|Farine de blé T55|42.0|kg
RC|Pate à paté croute|Product|Sel|0.84|kg
RC|Pate à paté croute|Product|Sucre semoule|0.84|kg
RC|Pate à paté croute|Product|Beurre|3.5|kg
RC|Pate à paté croute|Product|Oeuf solide|7.0|l
RC|Pate à paté croute|Product|Cognac|7.0|l
RC|Roux|Product|privilege margarine tourage pl|14.0|kg
RC|Roux|Product|Beurre|10.0|kg
RC|Roux|Product|Farine de blé T55|31.0|kg
RC|Sauce feuilleté bleu|Product|Lait|3.0|l
RC|Sauce feuilleté bleu|Product|Crème|2.0|l
RC|Sauce feuilleté bleu|Product|cord. bleu dinde|3.0|kg
RC|Sauce feuilleté bleu|Product|Noix|0.25|kg
RC|Sauce feuilleté bleu|Product|Roux|1.7|kg
RC|Sauce feuilleté bleu|Product|Poivre|0.01|kg
RC|Sauce saumon|Product|Saumon|60.0|kg
RC|Sauce saumon|Product|Cuisson|1.2|piece
RC|Sauce saumon|Product|Lait|30.0|l
RC|Sauce saumon|Product|Crème|30.0|l
RC|Sauce saumon|Product|Vin blanc|1.2|l
RC|Sauce saumon|Product|Echalote|1.0|kg
RC|Sauce saumon|Product|Fumet de crustacés|0.8|kg
RC|Sauce saumon|Product|Fumet de homard|0.8|kg
RC|Sauce saumon|Product|Sauce tomatina|1.0|kg
RC|Sauce saumon|Product|Roux|11.0|kg
RC|Sauce saumon|Product|Sel|0.72|kg
RC|Sauce saumon|Product|Poivre|0.03|kg
RC|Béchamel feuilleté jambon|Product|Lait|12.0|l
RC|Béchamel feuilleté jambon|Product|Crème|8.0|l
RC|Béchamel feuilleté jambon|Product|Roux|4.5|kg
RC|Béchamel feuilleté jambon|Product|Macardan|1.0|kg
RC|Béchamel feuilleté jambon|Product|Sel|0.2|kg
RC|Béchamel feuilleté jambon|Product|Poivre|0.01|kg
RC|Béchamel feuilleté jambon|Product|Muscade|0.05|kg
RC|Feuilleté écrevisse|Product|Ecrevisse|8.0|kg
RC|Feuilleté écrevisse|Recipe|Julienne De Légume Sous Recette|4.0|kg
RC|Feuilleté écrevisse|Product|Vin blanc|0.5|l
RC|Feuilleté écrevisse|Product|Crème|6.0|l
RC|Feuilleté écrevisse|Product|Lait|2.0|l
RC|Feuilleté écrevisse|Product|Fumet de crustacés|0.4|kg
RC|Feuilleté écrevisse|Product|Fumet de langoustine|0.1|kg
RC|Feuilleté écrevisse|Recipe|Sauce Pizza|0.5|l
RC|Feuilleté écrevisse|Product|Roux|2.5|kg
RC|Sauce fruits de mer|Product|Moule|9.0|kg
RC|Sauce fruits de mer|Product|Crevettes|6.0|kg
RC|Sauce fruits de mer|Product|Ecrevisse|4.0|kg
RC|Sauce fruits de mer|Product|St jacques|3.0|kg
RC|Sauce fruits de mer|Product|Champi|1.0|kg
RC|Sauce fruits de mer|Product|Vin blanc|1.0|l
RC|Sauce fruits de mer|Product|Echalote|0.5|kg
RC|Sauce fruits de mer|Product|Saumon|7.5|kg
RC|Sauce fruits de mer|Product|Merlan|7.5|kg
RC|Sauce fruits de mer|Product|Quenelle|2.0|kg
RC|Sauce fruits de mer|Product|Lait|20.0|l
RC|Sauce fruits de mer|Product|Crème|13.0|l
RC|Sauce fruits de mer|Product|Fumet de crustacés|0.4|kg
RC|Sauce fruits de mer|Product|Fumet de homard|0.4|kg
RC|Sauce fruits de mer|Product|Roux|9.0|kg
RC|Sauce fruits de mer|Product|Sel|0.33|kg
RC|Sauce fruits de mer|Product|Poivre|0.02|kg
RC|Sauce Feuilleté ris de veau|Product|Veau|60.0|kg
RC|Sauce Feuilleté ris de veau|Product|Morilles|5.75|kg
RC|Sauce Feuilleté ris de veau|Product|Sel|0.1|kg
RC|Sauce Feuilleté ris de veau|Product|Beurre|1.5|kg
RC|Sauce Feuilleté ris de veau|Product|Echalote|2.0|kg
RC|Sauce Feuilleté ris de veau|Product|Porto|3.0|l
RC|Sauce Feuilleté ris de veau|Recipe|Sauce Pizza Sous Recette|1.5|kg
RC|Sauce Feuilleté ris de veau|Product|Lait|40.0|l
RC|Sauce Feuilleté ris de veau|Product|Crème|36.0|l
RC|Sauce Feuilleté ris de veau|Recipe|Roux Sous Recette|22.0|kg
RC|Sauce Feuilleté ris de veau|Product|Poivre|0.4|kg
RC|Sauce Feuilleté ris de veau|Product|Cuisson|1.2|piece
RC|Sauce Feuilleté poulet|Product|Poulet|62.5|kg
RC|Sauce Feuilleté poulet|Product|Cuisson|1.25|piece
RC|Sauce Feuilleté poulet|Product|Morilles|11.5|kg
RC|Sauce Feuilleté poulet|Product|Beurre|1.5|kg
RC|Sauce Feuilleté poulet|Product|Echalote|1.5|kg
RC|Sauce Feuilleté poulet|Product|Sel|0.1|kg
RC|Sauce Feuilleté poulet|Product|Lait|48.0|l
RC|Sauce Feuilleté poulet|Product|Crème|36.0|l
RC|Sauce Feuilleté poulet|Product|Sauce girolles|2.0|kg
RC|Sauce Feuilleté poulet|Product|Champi|1.0|kg
RC|Sauce Feuilleté poulet|Product|Vin blanc|2.0|l
RC|Sauce Feuilleté poulet|Product|Sauce tomatina|2.0|kg
RC|Sauce Feuilleté poulet|Recipe|Roux Sous Recette|24.5|kg
RC|Sauce Feuilleté poulet|Product|Poivre|0.05|kg
RC|Sauce quiche|Product|Lait|10.0|l
RC|Sauce quiche|Product|Crème|8.0|l
RC|Sauce quiche|Product|Roux|1.3|kg
RC|Sauce quiche|Product|Sel|0.1|kg
RC|Sauce quiche|Product|Poivre|0.01|kg
RC|Sauce quiche|Product|Muscade|0.05|kg
RC|Sauce quiche|Product|Oeuf solide|5.0|piece
RC|Sauce quiche|Product|Jaune|1.0|l
RC|Sauce pizza|Product|Beurre|0.25|kg
RC|Sauce pizza|Product|Huile d'olive vierge extra|0.25|l
RC|Sauce pizza|Product|Oignons|1.5|kg
RC|Sauce pizza|Product|Sel|0.2|kg
RC|Sauce pizza|Product|Poivre|0.01|kg
RC|Sauce pizza|Product|Sucre semoule|500.0|kg
RC|Sauce pizza|Product|Origan|0.01|kg
RC|Sauce pizza|Product|Tomates|0.6|kg
RC|Sauce pizza|Product|Roux|1.0|kg
RC|Sauce ris de veau Louche|Product|Beurre|1.0|kg
RC|Sauce ris de veau Louche|Product|Echalote|1.0|kg
RC|Sauce ris de veau Louche|Product|Morilles|4.0|kg
RC|Sauce ris de veau Louche|Product|Cuisson|0.2|piece
RC|Sauce ris de veau Louche|Product|Veau|40.0|kg
RC|Sauce ris de veau Louche|Product|Porto|2.0|l
RC|Sauce ris de veau Louche|Recipe|Sauce Pizza Sous Recette|2.0|kg
RC|Sauce ris de veau Louche|Product|Crème|28.0|l
RC|Sauce ris de veau Louche|Product|Lait|2.0|l
RC|Sauce ris de veau Louche|Product|Sel|0.52|kg
RC|Sauce ris de veau Louche|Product|Poivre|0.03|kg
RC|Sauce ris de veau Louche|Recipe|Roux Sous Recette|4.0|kg
RC|Sauce Saint Jacques|Product|Beurre|0.5|kg
RC|Sauce Saint Jacques|Product|Echalote|1.0|kg
RC|Sauce Saint Jacques|Product|Vin blanc|2.0|l
RC|Sauce Saint Jacques|Product|Vermouth|2.0|l
RC|brioche aux grattons|Product|Gratons|5.0|kg
RC|brioche aux grattons|Product|Farine de blé T55|5.2|kg
RC|brioche aux grattons|Product|Sel|0.1|kg
RC|brioche aux grattons|Product|Sucre semoule|0.25|kg
RC|brioche aux grattons|Product|Levure|0.7|kg
RC|brioche aux grattons|Product|Oeuf solide|2.5|piece
RC|brioche aux grattons|Product|Beurre|1.0|kg
RC|brioche aux grattons|Product|Améliorant|0.2|kg
RC|Sauce quiche (2)|Product|Lait|10.0|l
RC|Sauce quiche (2)|Product|Crème|8.0|l
RC|Sauce quiche (2)|Product|Roux|1.3|kg
RC|Sauce quiche (2)|Product|Sel|0.1|kg
RC|Sauce quiche (2)|Product|Poivre|0.01|kg
RC|Sauce quiche (2)|Product|Muscade|0.05|kg
RC|Sauce quiche (2)|Product|Oeuf solide|5.0|piece
RC|Sauce quiche (2)|Product|Jaune|1.0|l
RC|Pate à croissant|Product|Farine de gruau|50.0|kg
RC|Pate à croissant|Product|privilege margarine tourage pl|6.0|kg
RC|Pate à croissant|Product|Beurre|6.0|kg
RC|Pate à croissant|Product|Sucre semoule|6.5|kg
RC|Pate à croissant|Product|Sel|0.95|kg
RC|Pate à croissant|Product|Levure|3.0|kg
RC|Pate à croissant|Product|Oeuf solide|4.0|l
RC|Pate à croissant|Product|Lait|9.0|l
RC|Pate à croissant|Product|Améliorant|0.4|kg
RC|Pate à paté croute **|Product|Farine de blé T55|42.0|kg
RC|Pate à paté croute **|Product|Sel|0.84|kg
RC|Pate à paté croute **|Product|Sucre semoule|0.84|kg
RC|Pate à paté croute **|Product|Beurre|3.5|kg
RC|Pate à paté croute **|Product|Oeuf solide|7.0|l
RC|Pate à paté croute **|Product|Cognac|7.0|l
RC|Feuilletés 4 portions|Recipe|Pate Feuilletés|0.42|kg
RC|Feuilletés 6 portions|Recipe|Pate Feuilletés|0.55|kg
RC|Feuilleté 8 personnes|Recipe|Pate Feuilletés|0.7|kg
RC|Quiche Lorraine|Recipe|Pate Brisée|0.115|kg
RC|Quiche Lorraine|Product|Gruyère|0.01|kg
RC|Quiche Lorraine|Product|Jambon|0.2|kg
RC|Quiche Lorraine|Product|Lardons|0.015|kg
RC|Quiche Lorraine|Recipe|Sauce Quiche|0.175|kg
RC|Quiche légumes|Recipe|Pate Brisée|0.115|kg
RC|Quiche légumes|Product|Mélange|0.05|kg
RC|Quiche légumes|Recipe|Julienne De Légume Sous Recette|5.0|kg
RC|Quiche légumes|Product|Gruyère|1.0|kg
RC|Quiche légumes|Product|Sel|0.03|kg
RC|Quiche légumes|Product|Poivre|0.03|kg
RC|Quiche légumes|Recipe|Sauce Quiche|0.18|kg
RC|Quiche thon tomates|Recipe|Pate Brisée|0.115|kg
RC|Quiche thon tomates|Product|Mélange|0.03|kg
RC|Quiche thon tomates|Product|Thon|3.0|kg
RC|Quiche thon tomates|Product|Gruyère|1.2|kg
RC|Quiche thon tomates|Product|Poudre tomate|0.4|kg
RC|Quiche thon tomates|Product|Tomates|4.0|kg
RC|Quiche thon tomates|Recipe|Sauce Pizza|0.8|kg
RC|Quiche thon tomates|Product|Tartare t|1.6|kg
RC|Quiche saumon asperges|Recipe|Pate Brisée|0.124|kg
RC|Quiche saumon asperges|Product|Saumon|0.03|kg
RC|Quiche saumon asperges|Product|Asperges|0.025|kg
RC|Quiche saumon asperges|Recipe|Sauce Quiche|0.15|kg
RC|Quiche chèvre épinard|Recipe|Pate Brisée|0.115|kg
RC|Quiche chèvre épinard|Product|Epinard|0.035|kg
RC|Quiche chèvre épinard|Product|Chèvre|0.03|kg
RC|Quiche chèvre épinard|Recipe|Sauce Quiche|0.16|kg
RC|Choux farcis|Product|Huile tournesol sye BI5L|0.5|l
RC|Choux farcis|Product|Oignons|1.5|kg
RC|Choux farcis|Product|Chair à saucisse|3.0|kg
RC|Choux farcis|Product|Chair tomate|2.0|kg
RC|Choux farcis|Product|Tomates|4.0|kg
RC|Choux farcis|Product|AIL|0.05|kg
RC|Choux farcis|Product|Sel|0.04|kg
RC|Choux farcis|Product|Poivre|0.04|kg
RC|Choux farcis|Product|Piment|0.001|kg
RC|Choux farcis|Recipe|Sauce Pizza|0.5|kg
RC|Choux farcis|Product|Chou|0.04|kg
RC|Choux farcis|Product|Veau|0.06|kg
RC|Fricassé de volaille|Product|Crème|10.0|l
RC|Fricassé de volaille|Product|Lait|4.0|l
RC|Fricassé de volaille|Product|Roux|1.8|kg
RC|Fricassé de volaille|Product|Champi|0.5|kg
RC|Fricassé de volaille|Product|Sauce girolles|0.5|kg
RC|Fricassé de volaille|Product|AIL|0.1|kg
RC|Fricassé de volaille|Product|Echalote|0.1|kg
RC|Fricassé de volaille|Product|Persil|0.04|kg
RC|Fricassé de volaille|Recipe|Sauce Pizza|1.0|kg
RC|Fricassé de volaille|Product|Sel|0.22|kg
RC|Fricassé de volaille|Product|Poivre|0.02|kg
RC|Fricassé de volaille|Product|Cuisson|1.3|piece
RC|Fricassé de volaille|Product|Poulet|1.0|kg
RC|Gratin dauphinois|Product|PDT|44.0|kg
RC|Gratin dauphinois|Product|Crème|12.0|l
RC|Gratin dauphinois|Product|Lait|12.0|l
RC|Gratin dauphinois|Product|Beurre|0.5|kg
RC|Gratin dauphinois|Product|Sel|0.43|kg
RC|Gratin dauphinois|Product|Poivre|0.03|kg
RC|Gratin dauphinois|Product|Muscade|0.01|kg
RC|Gratin dauphinois|Product|AIL|0.5|kg
RC|Paté pomme de terre|Recipe|Pate Feuilletée|0.35|kg
RC|Paté pomme de terre|Recipe|Gratin Dauphinois|0.55|kg
RC|Paté pomme de terre|Product|AIL|0.005|kg
RC|Paté pomme de terre|Product|Echalote|0.005|kg
RC|Paté pomme de terre|Product|Persil|0.005|kg
RC|Paté pomme de terre|Product|Crème|0.04|l
RC|Paté pomme de terre (2)|Recipe|Gratin Dauphinois|0.275|kg
RC|Paté pomme de terre (2)|Product|AIL|0.003|kg
RC|Paté pomme de terre (2)|Product|Echalote|0.003|kg
RC|Paté pomme de terre (2)|Product|Persil|0.003|kg
RC|Paté pomme de terre (2)|Product|Crème|0.02|l
RC|Aligot|Product|Aligot|2.0|kg
RC|Aligot|Product|Crème|0.3|l
RC|Aligot|Product|AIL|0.02|kg
RC|Aligot|Product|Poudre purée|0.08|kg
RC|Aligot|Product|Poivre|0.004|kg
RC|Aligot|Product|Muscade|0.001|kg
RC|Purée|Product|Crème|0.5|kg
RC|Purée|Product|Beurre|0.15|kg
RC|Purée|Product|Poudre purée|0.4|kg
RC|Tagliatelle écrevisses|Product|Ecrevisse|8.0|kg
RC|Tagliatelle écrevisses|Recipe|Julienne De Légume Sous Recette|3.0|kg
RC|Tagliatelle écrevisses|Product|Crème|4.0|l
RC|Tagliatelle écrevisses|Product|Fumet de crustacés|0.4|kg
RC|Tagliatelle écrevisses|Product|Sel|0.1|kg
RC|Tagliatelle écrevisses|Product|Poivre|0.01|kg
RC|Tagliatelle écrevisses|Product|Piment|0.001|kg
RC|Tagliatelle écrevisses|Product|Roux|0.9|kg
RC|Beurre escargot|Product|Persil|0.75|kg
RC|Beurre escargot|Product|Echalote|0.12|kg
RC|Beurre escargot|Product|AIL|0.12|kg
RC|Beurre escargot|Product|Sel|0.15|kg
RC|Beurre escargot|Product|Poivre|0.01|kg
RC|Beurre escargot|Product|Thym|0.006|kg
RC|Beurre escargot|Product|Muscade|0.006|kg
RC|Beurre escargot|Product|Noix|0.2|kg
RC|Beurre escargot|Product|Anchois|0.15|kg
RC|Beurre escargot|Product|Ricard|0.1|l
RC|Beurre escargot|Product|Beurre|6.0|kg
RC|Quiches|Recipe|Sauce Quiche|0.18|kg
RC|Quiches|Recipe|Pate Brisée|0.12|kg
RC|Quiche asperge / saumon|Recipe|Sauce Quiche|0.18|kg
RC|Quiche asperge / saumon|Recipe|Pate Brisée|0.12|kg
RC|Quiche asperge / saumon|Product|Saumon|20.0|kg
RC|Quiche asperge / saumon|Product|Asperges|30.0|kg
RC|Quiche au légumes|Recipe|Sauce Quiche|0.18|kg
RC|Quiche au légumes|Recipe|Pate Brisée|0.12|kg
RC|Quiche au légumes|Recipe|Légumes Sous Recettes|0.05|kg
RC|salade poulet barquette|Product|Poulet|0.16|kg
RC|salade poulet barquette|Product|Salade|0.05|kg
RC|salade poulet barquette|Recipe|Carotte Rapées Sous Recette|0.1|kg
RC|salade poulet barquette|Recipe|Salade Du Moment Sous Recette|0.1|kg
RC|tarte aux myrtilles|Recipe|Pate Sucrée Sous Recette|1.3|kg
RC|tarte aux myrtilles|Recipe|Frangipane Sous Recette|0.9|kg
RC|tarte aux myrtilles|Product|Myrtille|2.0|kg
RC|tarte aux myrtilles|Product|Nappage|0.7|kg
RC|Frangipane|Recipe|TPT sous recette|4.2|kg
RC|Frangipane|Product|Blanc|2.0|l
RC|Frangipane|Product|Beurre|1.5|kg
RC|Parmentier de canard Barquette|Product|Barquettes|0.05|piece
RC|Parmentier de canard Barquette|Product|Purée pdt|0.25|kg
RC|Parmentier de canard Barquette|Product|Canard|0.1|kg
RC|pied de cochon sous vide|Recipe|Farce À Pied Sous Recette|0.08|kg
RC|Ris de veau aux morilles louche barquette|Product|Barquettes|0.05|piece
RC|Ris de veau aux morilles louche barquette|Recipe|Sauce Ris De Veau Louche Sous Recette|0.25|kg
RC|Spaghetti bolognaise Barquette|Product|Barquettes|0.05|piece
RC|Spaghetti bolognaise Barquette|Recipe|Spaghetti Bolognaise Sous Recette|0.005|kg
RC|Spaghetti bolognaise Barquette|Product|Spaghetti|0.245|kg
RC|Spaghetti bolognaise Barquette|Recipe|Bolognaise sous recette|0.1|kg
RC|purée saucisses Barquette|Product|Barquettes|0.05|piece
RC|purée saucisses Barquette|Recipe|Purée Sous Recette|0.25|kg
RC|tomates farcies|Product|Tomates|1.0|kg
RC|tomates farcies|Recipe|Farce À Tomate Sous Recette|0.15|kg
RC|tomates farcies|Product|Riz US|0.27|kg
RC|tomates farcies|Product|Lardons|0.08|kg
RC|tomates farcies|Product|Veau|0.1|kg
RC|tomates farcies|Product|Beurre|0.25|kg
RC|fromage blanc|Product|Bol|0.01|piece
RC|fromage blanc|Product|From. blanc|0.18|kg
RC|fromage blanc|Product|Clementine|0.016|kg
RC|fromage blanc|Product|Fraise|0.015|kg
RC|fromage blanc|Product|Brisure de nougat|0.02|kg
RC|salade de fruit|Recipe|jus de fruit sous recette|0.05|kg
RC|salade de fruit|Product|Banane|0.04|kg
RC|salade de fruit|Product|Pomme|0.04|kg
RC|salade de fruit|Product|Ananas|0.04|kg
RC|salade de fruit|Product|Clementine|0.04|kg
RC|salade de fruit|Product|Raisin|0.04|kg
RC|salade de fruit|Product|Fraise|0.04|kg
RC|salade de fruit|Product|Bol|0.01|piece
RC|choux carottes|Product|Carotte|1.0|kg
RC|choux carottes|Recipe|mayonnaise sous recette|0.5|kg
RC|choux carottes|Product|Vinaigre|0.05|kg
RC|choux carottes|Product|Chou|0.5|kg
RC|choux carottes|Product|Ketchup|0.05|kg
RC|choux carottes|Product|Poivre|0.005|kg
RC|Lentilles|Product|Lentilles|1.5|kg
RC|Lentilles|Product|Maïs|0.2|kg
RC|Lentilles|Product|Tomates|0.05|kg
RC|Lentilles|Product|Vinaigre|0.15|kg
RC|Océance|Product|Thaï|0.5|kg
RC|Océance|Product|Basmati|0.5|kg
RC|Océance|Product|Poivrons|0.1|kg
RC|Océance|Product|Crevettes|0.3|kg
RC|Océance|Product|Surimi|0.25|kg
RC|Océance|Product|Mayonnaise|0.5|kg
RC|Océance|Product|Ketchup|0.05|kg
RC|pommes de terre|Product|PDT|1.25|kg
RC|pommes de terre|Product|Persil|0.02|kg
RC|pommes de terre|Product|Oeuf solide|0.15|piece
RC|pommes de terre|Product|Tomates|0.05|kg
RC|pommes de terre|Product|cornichons|0.05|kg
RC|pommes de terre|Product|Vinaigre|0.15|kg
RC|poulet pâtes|Product|Pâtes trois couleurs|1.2|kg
RC|poulet pâtes|Product|Poulet|0.15|kg
RC|poulet pâtes|Product|Tomates|0.05|kg
RC|poulet pâtes|Product|Oignons|0.05|kg
RC|poulet pâtes|Recipe|Vinaigrette sous recette|0.25|l
RC|riz niçois|Product|Thaï|0.5|kg
RC|riz niçois|Product|Basmati|0.5|kg
RC|riz niçois|Product|Poivrons|0.1|kg
RC|riz niçois|Product|Maïs|0.15|kg
RC|riz niçois|Product|Olive|0.05|kg
RC|riz niçois|Product|Thon|0.3|kg
RC|riz niçois|Product|Vinaigre|0.2|l
RC|macédoine|Product|Macédoine|1.25|kg
RC|macédoine|Recipe|mayonnaise sous recette|0.25|kg
RC|macédoine|Product|Sel|0.02|kg
RC|haricots verts|Product|Haricots|1.3|kg
RC|haricots verts|Product|Persil|0.05|kg
RC|haricots verts|Recipe|vinaigrette balsamique sous recette|0.15|kg
RC|piemontaise|Product|PDT|1.25|kg
RC|piemontaise|Product|Persil|0.05|kg
RC|piemontaise|Product|Oeuf solide|0.15|piece
RC|piemontaise|Product|Tomates|0.05|kg
RC|piemontaise|Product|cornichons|0.05|kg
RC|piemontaise|Recipe|mayonnaise sous recette|0.25|kg
RC|piemontaise|Product|Vinaigre|0.05|kg
RC|piemontaise|Product|Jambon|0.02|kg
RC|melon|Product|Tomates|0.5|kg
RC|melon|Product|Mozza|0.65|kg
RC|melon|Product|Oignons|0.1|kg
RC|melon|Product|Sel|0.006|kg
RC|melon|Product|Poivre|0.006|kg
RC|melon|Product|Piment d'Espelette|0.002|kg
RC|melon|Product|Menthe fraîche|0.03|kg
RC|melon|Product|Huile d'olive vierge extra|0.1|kg
RC|melon|Product|Vinaigre balsamique|0.012|kg
RC|melon|Product|Citron|0.008|kg
RC|Aligot saucisse|Product|Barquettes|0.05|piece
RC|Aligot saucisse|Product|Aligot|0.3|kg
RC|asperges au jambon|Product|Barquettes|1.0|kg
RC|asperges au jambon|Product|Macédoine|0.125|kg
RC|asperges au jambon|Recipe|mayonnaise sous recette|0.03|kg
RC|asperges au jambon|Product|Asperges|0.1|kg
RC|asperges au jambon|Product|Tomates|0.015|kg
EXPORT_DATA

def parse_bool(str)
  str == "true"
end

def parse_nil(str)
  str.nil? || str.strip.empty? ? nil : str.strip
end

def parse_decimal(str)
  val = parse_nil(str)
  val.nil? ? nil : BigDecimal(val)
end

puts "=" * 60
puts "CostChef Production Import"
puts "=" * 60
puts ""

# Step 1: Find user
user = User.find_by(email: EMAIL)
unless user
  abort "ERROR: User with email '#{EMAIL}' not found. Aborting."
end
puts "Found user: #{user.email} (id: #{user.id})"

# Parse all lines
suppliers_data    = []
products_data     = []
purchases_data    = []
recipes_data      = []
components_data   = []

DATA.each_line do |line|
  line = line.chomp
  next if line.empty?

  parts = line.split("|", -1)
  prefix = parts[0]

  case prefix
  when "S"
    suppliers_data << { name: parts[1], active: parse_bool(parts[2]) }
  when "P"
    products_data << {
      name: parts[1],
      base_unit: parts[2],
      unit_weight_kg: parse_decimal(parts[3]),
      avg_price_per_kg: parse_decimal(parts[4]),
      dehydrated: parse_bool(parts[5]),
      rehydration_coefficient: parse_decimal(parts[6])
    }
  when "PP"
    purchases_data << {
      product_name: parts[1],
      supplier_name: parts[2],
      package_quantity: BigDecimal(parts[3]),
      package_unit: parts[4],
      package_price: BigDecimal(parts[5]),
      package_quantity_kg: BigDecimal(parts[6]),
      price_per_kg: BigDecimal(parts[7]),
      active: parse_bool(parts[8])
    }
  when "R"
    recipes_data << {
      name: parts[1],
      description: parse_nil(parts[2]),
      cooking_loss_percentage: BigDecimal(parts[3]),
      sellable_as_component: parse_bool(parts[4]),
      has_tray: parse_bool(parts[5]),
      sold_by_unit: parse_bool(parts[6])
    }
  when "RC"
    components_data << {
      recipe_name: parts[1],
      component_type: parts[2],
      component_name: parts[3],
      quantity_kg: BigDecimal(parts[4]),
      quantity_unit: parts[5]
    }
  end
end

puts ""
puts "Parsed data:"
puts "  Suppliers:          #{suppliers_data.size}"
puts "  Products:           #{products_data.size}"
puts "  Product Purchases:  #{purchases_data.size}"
puts "  Recipes:            #{recipes_data.size}"
puts "  Recipe Components:  #{components_data.size}"
puts ""

# Step 2-8: Execute in transaction
ActiveRecord::Base.transaction do
  # Step 2: Purge existing data in FK order
  puts "Purging existing data for user #{user.email}..."

  recipe_ids = user.recipes.pluck(:id)
  if recipe_ids.any?
    rc_count = RecipeComponent.where(parent_recipe_id: recipe_ids).delete_all
    puts "  Deleted #{rc_count} recipe components"
  end

  r_count = Recipe.where(user_id: user.id).delete_all
  puts "  Deleted #{r_count} recipes"

  product_ids = user.products.pluck(:id)
  if product_ids.any?
    pp_count = ProductPurchase.where(product_id: product_ids).delete_all
    puts "  Deleted #{pp_count} product purchases"
  end

  p_count = Product.where(user_id: user.id).delete_all
  puts "  Deleted #{p_count} products"

  s_count = Supplier.where(user_id: user.id).delete_all
  puts "  Deleted #{s_count} suppliers"

  puts ""

  # Step 3: Create suppliers
  puts "Creating suppliers..."
  supplier_map = {}
  suppliers_data.each do |s|
    supplier = Supplier.create!(
      user: user,
      name: s[:name],
      active: s[:active]
    )
    supplier_map[s[:name]] = supplier
  end
  puts "  Created #{supplier_map.size} suppliers"

  # Step 4: Create products (without avg_price_per_kg initially)
  puts "Creating products..."
  product_map = {}
  products_data.each do |p|
    product = Product.create!(
      user: user,
      name: p[:name],
      base_unit: p[:base_unit],
      unit_weight_kg: p[:unit_weight_kg],
      dehydrated: p[:dehydrated],
      rehydration_coefficient: p[:rehydration_coefficient]
    )
    product_map[p[:name]] = { record: product, avg_price: p[:avg_price_per_kg] }
  end
  puts "  Created #{product_map.size} products"

  # Step 5: Create purchases (skip validations/callbacks)
  puts "Creating product purchases..."
  created_purchases = 0
  purchases_data.each do |pp|
    product_entry = product_map[pp[:product_name]]
    unless product_entry
      puts "  WARNING: Product '#{pp[:product_name]}' not found, skipping purchase"
      next
    end
    product = product_entry[:record]

    supplier = supplier_map[pp[:supplier_name]]
    unless supplier
      puts "  WARNING: Supplier '#{pp[:supplier_name]}' not found, skipping purchase"
      next
    end

    purchase = ProductPurchase.new(
      product: product,
      supplier: supplier,
      package_quantity: pp[:package_quantity],
      package_unit: pp[:package_unit],
      package_price: pp[:package_price],
      package_quantity_kg: pp[:package_quantity_kg],
      price_per_kg: pp[:price_per_kg],
      active: pp[:active]
    )
    purchase.save!(validate: false)
    created_purchases += 1
  end
  puts "  Created #{created_purchases} product purchases"

  # Update avg_price_per_kg on products using update_columns
  puts "Setting avg_price_per_kg on products..."
  updated_prices = 0
  product_map.each do |_name, entry|
    product = entry[:record]
    avg_price = entry[:avg_price]
    if avg_price
      product.update_columns(avg_price_per_kg: avg_price)
      updated_prices += 1
    end
  end
  puts "  Updated #{updated_prices} product prices"

  # Step 6: Create recipes
  puts "Creating recipes..."
  recipe_map = {}
  recipes_data.each do |r|
    recipe = Recipe.create!(
      user: user,
      name: r[:name],
      description: r[:description],
      cooking_loss_percentage: r[:cooking_loss_percentage],
      sellable_as_component: r[:sellable_as_component],
      has_tray: false,
      sold_by_unit: r[:sold_by_unit]
    )
    recipe_map[r[:name]] = recipe
  end
  puts "  Created #{recipe_map.size} recipes"

  # Step 7: Create recipe components
  puts "Creating recipe components..."
  created_components = 0
  skipped_components = 0
  components_data.each do |rc|
    parent_recipe = recipe_map[rc[:recipe_name]]
    unless parent_recipe
      puts "  WARNING: Parent recipe '#{rc[:recipe_name]}' not found, skipping component"
      skipped_components += 1
      next
    end

    if rc[:component_type] == "Product"
      component = product_map[rc[:component_name]]
      unless component
        puts "  WARNING: Product component '#{rc[:component_name]}' not found, skipping"
        skipped_components += 1
        next
      end
      component_record = component[:record]
      component_type = "Product"
    elsif rc[:component_type] == "Recipe"
      component_record = recipe_map[rc[:component_name]]
      unless component_record
        puts "  WARNING: Recipe component '#{rc[:component_name]}' not found, skipping"
        skipped_components += 1
        next
      end
      component_type = "Recipe"
    else
      puts "  WARNING: Unknown component type '#{rc[:component_type]}', skipping"
      skipped_components += 1
      next
    end

    RecipeComponent.create!(
      parent_recipe_id: parent_recipe.id,
      component_type: component_type,
      component_id: component_record.id,
      quantity_kg: rc[:quantity_kg],
      quantity_unit: rc[:quantity_unit]
    )
    created_components += 1
  end
  puts "  Created #{created_components} recipe components"
  puts "  Skipped #{skipped_components} recipe components" if skipped_components > 0

  # Step 8: Recalculate all recipe costs
  puts "Recalculating recipe costs..."
  # Subrecipes first (bottom-up)
  user.recipes.where(sellable_as_component: true).find_each do |recipe|
    Recipes::Recalculator.call(recipe)
  end
  # Then main recipes
  user.recipes.where(sellable_as_component: false).find_each do |recipe|
    Recipes::Recalculator.call(recipe)
  end
  with_cost = user.recipes.where("cached_cost_per_kg > 0").count
  puts "  #{with_cost} recipes with calculated cost"

  # Step 9: Summary
  puts ""
  puts "=" * 60
  puts "IMPORT COMPLETE"
  puts "=" * 60
  puts ""
  puts "User:              #{user.email}"
  puts "Suppliers:         #{supplier_map.size}"
  puts "Products:          #{product_map.size}"
  puts "Purchases:         #{created_purchases}"
  puts "Recipes:           #{recipe_map.size}"
  puts "Recipe Components: #{created_components}"
  puts "With cost:         #{with_cost}"
  puts ""
  puts "All data imported successfully within a single transaction."
end
