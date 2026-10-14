# Refonte design — questions ouvertes

Notées pendant l'implémentation (branche locale `design/refonte-core`, **rien n'est poussé**).
Pour chaque question, j'indique ce que j'ai fait en attendant ta réponse.

## À trancher par toi

1. **Couleur de marque définitive.** Aubergine (`#5A2D4F`) par défaut. Elle se change en
   une ligne : `--brand` dans `app/assets/stylesheets/costchef/_tokens.scss`. Toute l'app suit
   (boutons, liens, bloc prix, focus).
   ✅ Décision de Tom (14 oct.) : on garde l'aubergine pour l'instant.

2. ✅ **Vocabulaire — validé par Tom (14 oct.).** Appliqué partout dans l'app, y compris les
   messages de confirmation (« Achat ajouté », plus « Conditionnement »).
   Reste : les fichiers exportés (CSV, Excel) gardent les anciens libellés (« PVC HT », onglet
   « Tarifs »). À traiter avec la question 7.
   | Avant | Maintenant |
   |---|---|
   | PON / MOY | Prix moyen pondéré / Moyenne simple |
   | Conditionnements | Achats |
   | Écarts types (CV%) | Prix instables (variation) |
   | Référentiel pièces | Poids des pièces |
   | Barquettes & Coefficient | Coefficient et barquettes |
   | Tarifs (onglet) | Recettes › « Prix de vente » |
   | PVC HT / TTC | Prix de vente conseillé HT / TTC |

3. ✅ **Messages en français — fait (14 oct.).** Gems `rails-i18n` et `devise-i18n`, langue par
   défaut française, noms des champs traduits (`config/locales/fr.yml`) : connexion, erreurs de
   formulaire, emails de mot de passe oublié et de déblocage, pagination, pages d'erreur 404/422/500.
   Effet de bord corrigé : les pluriels (« 3 recette ») — règles du pluriel français ajoutées dans
   `config/initializers/inflections.rb` (fichier de règles de langue, sans lien avec la sécurité).
   Les messages natifs du navigateur (« Veuillez remplir ce champ ») suivent la langue du navigateur.

4. **Recherche globale (⌘K).** Présente dans les maquettes, mais elle n'existe pas dans l'app.
   Je ne l'ai pas mise pour ne pas afficher un champ qui ne fait rien.
   ✅ Décision de Tom (14 oct.) : abandonnée.

5. **Boutons « Convertir en recette / en sous-recette ».** Ils étaient masqués dans le code
   (`if false`, avec un TODO « à réactiver »).
   ✅ Réactivés (14 oct.) dans l'en-tête de la fiche recette. Passer en sous-recette retire la
   barquette et la vente à l'unité (une sous-recette ne peut pas les avoir) ; repasser en recette
   finale une sous-recette déjà utilisée est possible, avec un avertissement : elle reste dans les
   recettes qui l'utilisent, mais sa quantité n'y est plus modifiable (même règle qu'avant).

6. ✅ **Retrait complet de Bootstrap — fait (14 oct.).** Retiré de `assets.rb`, `pagy.rb` et
   `package.json`. Seules les icônes (Bootstrap Icons, une bibliothèque séparée) restent.

7. ✅ **Exports — faits (14 oct.).** Les 4 exports Excel passent aux couleurs CostChef (en-têtes
   aubergine, lignes de sous-recettes sur la teinte de marque, fichier signé « CostChef ») et au
   nouveau vocabulaire, ainsi que les en-têtes des CSV. Unités en toutes lettres (« pièce(s) »),
   prix des barquettes au format français. Fichiers renommés : `prix-de-vente-…`, `poids-des-pieces-…`.
   La structure des tableaux (colonnes, ordre, onglets) ne change pas.

8. ✅ **Logo Lassalas — fait (14 oct.).** Il remplace le logo rond, à côté du nom CostChef, dans
   le menu et sur les écrans de connexion. Comme dans l'ancienne version, il s'affiche pour tous
   les comptes : si d'autres traiteurs utilisent l'app, il faudra un logo par compte.

## À valider avec Quentin

9. **Vocabulaire Bureau Core.** Core n'a pas encore de noms pour les états (survol) ni pour
   les teintes douces. J'ai ajouté 3 tokens dérivés, regroupés et commentés dans `_tokens.scss` :
   `--primary-hover`, `--secondary-border`, `--brand-selection`. Il faudra les faire entrer dans
   Core, ou les renommer.

10. **Expression « app » de Bureau Core.** CostChef définit les premières valeurs « app »
    (texte compact, rayons 6–20 px, cibles tactiles 44 px). À reporter dans
    `bureau-design-system` sous `brands/costchef.json` si Quentin est d'accord.

## Constats (rien à décider tout de suite)

11. **Tests.** 855 tests, **0 échec** (14 oct.). Les 2 tests qui échouaient déjà sur `master`
    ont été réalignés sur le comportement actuel du code (ce sont eux qui étaient périmés) :
    - `spec/requests/products_spec.rb:104` attend l'ancien en-tête de l'export CSV produits.
    - `spec/requests/products_spec.rb:270` attend un retour à la liste après modification d'un
      produit ; le code renvoie sur la fiche du produit depuis une modification de septembre.
    Un troisième test qui échouait sur `master` (plats du jour, « 400g » sans espace) passe
    maintenant : j'ai aligné son texte sur la nouvelle page.

12. **Bugs corrigés au passage** (ils existaient avant la refonte) :
    - Le bouton « Annuler » de la modification d'un achat ne faisait rien (bloqué par la
      politique de sécurité du navigateur).
    - Le compteur de caractères de la description de recette ne marchait pas.
    - Le badge « Recette » de la fiche produit était invisible.
    - Le lien « Créer un compte » de la page de connexion menait à une erreur (l'inscription
      se fait sur invitation).
    - Enregistrer le formulaire de modification d'une recette ne donnait aucun retour à l'écran.
    - Ajouter un achat sans choisir de fournisseur dans la liste effaçait la fiche produit.
    - L'édition en ligne d'une quantité perdait son unité (250 g devenait 0,25 kg).
    - La fenêtre de gestion des abonnements (admin) ne s'ouvrait plus sans Bootstrap.

13. **Compte pour la preview.** Le compte Lassalas local (`dp.lassalas@outlook.fr`, 198 produits)
    a un mot de passe que je n'ai pas. Les comptes de test (`christophe@traiteur.fr`,
    `admin@costchef.fr`, mot de passe `password123`) ont peu de données mais suffisent pour
    tout parcourir.

14. **Performance.** Le compteur « Prix instables » de l'accueil calcule la variation produit
    par produit (comme avant la refonte). Avec plus de 1 000 produits, l'accueil peut être lent.
    À optimiser si besoin (un seul calcul en base).

15. **Tableaux tronqués sur ordinateur — corrigé (14 oct., signalé par Tom).** Les tableaux
    avaient une largeur minimale pensée pour le téléphone ; sur la fiche produit (colonne de
    droite présente), le tableau des achats dépassait et la poubelle était coupée. Même défaut
    sur la composition des recettes, la liste des produits, les fournisseurs et l'admin.
    Vérifié page par page à 768, 1024, 1280, 1440 et 1920 px : plus aucun débordement. Corrigé
    aussi : sur téléphone, toute la page pouvait glisser sur le côté ; le choix « pièce(s) » et
    les champs de recherche étaient coupés.
