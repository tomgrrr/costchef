# Refonte design — questions ouvertes

Notées pendant l'implémentation (branche locale `design/refonte-core`, **rien n'est poussé**).
Pour chaque question, j'indique ce que j'ai fait en attendant ta réponse.

## À trancher par toi

1. **Couleur de marque définitive.** Aubergine (`#5A2D4F`) par défaut. Elle se change en
   une ligne : `--brand` dans `app/assets/stylesheets/costchef/_tokens.scss`. Toute l'app suit
   (boutons, liens, bloc prix, focus).
   → En attendant : aubergine.

2. **Vocabulaire.** J'ai remplacé le jargon par des mots du métier. Lassalas a peut-être ses
   habitudes : à valider avec eux.
   | Avant | Maintenant |
   |---|---|
   | PON / MOY | Prix moyen pondéré / Moyenne simple |
   | Conditionnements | Achats |
   | Écarts types (CV%) | Prix instables (variation) |
   | Référentiel pièces | Poids des pièces |
   | Barquettes & Coefficient | Coefficient et barquettes |
   | Tarifs (onglet) | Recettes › « Prix de vente » |
   | PVC HT / TTC | Prix de vente conseillé HT / TTC |

3. **Messages en anglais.** Les messages de connexion (« Signed out successfully. ») et les
   erreurs de formulaire par défaut (« can't be blank ») restent en anglais : l'app n'a pas de
   traduction française. Il faut ajouter les gems `rails-i18n` et `devise-i18n` et passer la
   langue par défaut en français (`config/application.rb`). Pas fait sans ton accord.

4. **Recherche globale (⌘K).** Présente dans les maquettes, mais elle n'existe pas dans l'app.
   Je ne l'ai pas mise pour ne pas afficher un champ qui ne fait rien. On la construit ?
   → En attendant : absente.

5. **Boutons « Convertir en recette / en sous-recette ».** Ils étaient masqués dans le code
   (`if false`, avec un TODO « à réactiver »). Je ne les ai pas repris. On les réactive ?

6. **Retrait complet de Bootstrap.** Le CSS et le JS de Bootstrap ne sont plus chargés. Il en
   reste des traces dans deux fichiers de configuration (`config/initializers/assets.rb`,
   `config/initializers/pagy.rb`) et dans `package.json` (`bootstrap`, `@popperjs/core`).
   La règle du projet demande ton accord avant de toucher aux initializers. Je les retire ?

7. **Exports Excel.** Ils gardent l'ancienne palette (bleu marine, gris). Je les passe aux
   couleurs CostChef ?

8. **Logo Lassalas.** Il n'est plus affiché (CostChef a sa propre marque). Le fichier
   `app/assets/images/logo.jpg` est toujours là. Je le supprime, ou on prévoit un co-branding
   (logo du traiteur dans l'app ou sur les exports) ?

## À valider avec Quentin

9. **Vocabulaire Bureau Core.** Core n'a pas encore de noms pour les états (survol) ni pour
   les teintes douces. J'ai ajouté 3 tokens dérivés, regroupés et commentés dans `_tokens.scss` :
   `--primary-hover`, `--secondary-border`, `--brand-selection`. Il faudra les faire entrer dans
   Core, ou les renommer.

10. **Expression « app » de Bureau Core.** CostChef définit les premières valeurs « app »
    (texte compact, rayons 6–20 px, cibles tactiles 44 px). À reporter dans
    `bureau-design-system` sous `brands/costchef.json` si Quentin est d'accord.

## Constats (rien à décider tout de suite)

11. **Tests.** 840 tests (636 au départ). Il en reste **2 en échec, déjà en échec sur `master`**
    avant la refonte, et sans lien avec le design : ce sont les tests qui ne correspondent plus
    au code, pas l'inverse.
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
