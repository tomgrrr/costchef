# CostChef - Règles de Développement & Architecture (v1.5)

## 1. Principes de Codage (Anti-Bug)
- **Fonctions Courtes :** Maximum 10 lignes par méthode. Si une méthode est plus longue, elle doit être décomposée en sous-méthodes privées.
- **Responsabilité Unique (SRP) :** Un service ne fait qu'une seule chose (ex: calculer un prix, pas envoyer un email en plus).
- **Zéro Callback ActiveRecord :** INTERDICTION d'utiliser `after_save`, `before_create`, etc., pour la logique métier ou les calculs. Tout passe par les Services.
- **Fail Fast :** Valider les données en entrée de service et lever des erreurs explicites.

## 2. Structure de la Base de Données (Source de Vérité)
- **User :** Possède tout. `markup_coefficient` obligatoire (défaut 1.0).
- **Product :** Unité pivot (`base_unit`) parmi `[kg, l, piece]`.
    - Si `base_unit == 'piece'`, `unit_weight_kg` est OBLIGATOIRE.
- **ProductPurchase :** Table de prix. Unités d'achat : `[kg, g, l, cl, ml, piece]`.
    - Champ `active: boolean` pour filtrer les prix obsolètes.
- **Recipe :** Champ `cooking_loss_percentage` (0-100).
    - `sellable_as_component` définit si elle peut être une sous-recette.
- **RecipeComponent :** Table polymorphe (`component_type`: Product ou Recipe).
    - **Règle d'or :** Profondeur maximale de 1 niveau de sous-recette.
- **DailySpecial :** Historique indépendant pour viandes/poissons/accompagnements.

## 3. Workflow de Calcul (Ordre Impératif)
Toute modification de prix doit suivre cette chaîne via le `Recalculations::CascadeDispatcher` :
1. `Prices::PerKgCalculator` : Convertit l'achat en prix/kg standard.
2. `Prices::ProductAvgCalculator` : Recalcule la moyenne pondérée du produit.
3. `Prices::RecipeCostCalculator` : Recalcule le coût de toutes les recettes utilisant le produit.
4. **Cascade :** Si une recette modifiée est utilisée comme sous-recette, recalculer la recette parente.

## 4. Règles de Suppression (Safety)
- **Product :** Bloquer la suppression si présent dans une `RecipeComponent`.
- **Supplier :** Bloquer la suppression si des `ProductPurchase` existent (sauf si force=true).
- **TraySize :** Si supprimé, mettre à `null` dans les recettes (pas de destruction de recette).

## 5. Conventions de Nommage
- Services : `app/services/{domaine}/{action}_service.rb` -> `Prices::PerKgCalculator.call(obj)`
- Tester chaque service avec un RSpec dédié avant de l'intégrer aux contrôleurs.
