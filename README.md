# README

📖 À propos
CostChef est une application web SaaS qui permet aux traiteurs de calculer précisément le coût de revient matières de leurs recettes. Fini les tableurs Excel avec leurs erreurs de calcul et leurs mises à jour fastidieuses !
🎯 Le problème résolu
Les chefs traiteurs passent des heures sur Excel à :

❌ Calculer manuellement le coût de chaque recette
❌ Mettre à jour les prix dans des dizaines de fichiers
❌ Comparer leurs recettes pour optimiser leurs marges
❌ Gérer les incohérences entre recettes

✨ La solution CostChef

✅ Référentiel centralisé : un seul endroit pour tous vos produits et prix
✅ Calculs automatiques : coût total, poids total, et coût au kilo calculés instantanément
✅ Recalcul intelligent : changez un prix, toutes vos recettes se mettent à jour automatiquement
✅ Comparaison facile : triez vos recettes par coût au kilo pour optimiser votre carte
✅ Isolation des données : chaque utilisateur a son propre espace sécurisé


🚀 Fonctionnalités MVP
📦 Gestion des Produits

CRUD complet (Créer, Lire, Modifier, Supprimer)
Référentiel centralisé avec prix unitaires
Recherche et tri par nom ou prix
Validation : impossible de supprimer un produit utilisé dans une recette

🍽️ Gestion des Recettes

CRUD complet avec gestion d'ingrédients
Ajout/modification/suppression d'ingrédients avec quantités
Calcul automatique du coût total
Calcul automatique du poids total
Calcul automatique du coût au kilogramme (€/kg)
Fonction "Dupliquer une recette"
Tri par coût au kilo

🔄 Recalculs Automatiques

Modification d'un prix de produit → recalcul instantané de toutes les recettes concernées
Ajout/modification/suppression d'un ingrédient → recalcul de la recette
Notifications des recettes impactées

🔐 Authentification & Abonnements

Système d'authentification sécurisé (Devise)
Gestion des abonnements (actif/inactif)
Rôle administrateur
Isolation stricte des données par utilisateur


🛠️ Stack Technique
Backend

Framework : Ruby on Rails 7.1
Base de données : PostgreSQL 14+
ORM : Active Record
Authentification : Devise
Callbacks : Pour calculs automatiques

Frontend

Framework CSS : Bootstrap 5
Templates : ERB (Embedded Ruby)
JavaScript : Stimulus (Rails 7)
Responsive : Desktop + Tablette

Architecture

Pattern : MVC (Model-View-Controller)
4 tables principales : users, products, recipes, recipe_ingredients
11 index stratégiques pour des performances < 5ms
Contraintes d'intégrité : CHECK, UNIQUE, NOT NULL, FK avec ON DELETE


📊 Architecture Base de Données
users (1) ──────────────────> (N) products
  │                                  │
  │                                  │
  └──────────────────> (N) recipes  │
                            │        │
                            └────────┘
                         (via recipe_ingredients)
Relations principales

Un utilisateur possède plusieurs produits et recettes
Une recette contient plusieurs ingrédients (produits avec quantités)
Suppression d'un user → CASCADE sur products et recipes
Suppression d'un product utilisé → RESTRICT avec erreur explicite

📄 Pour le schéma complet, consultez le PRD.md

📂 Structure du Projet
costchef/
├── app/
│   ├── controllers/        # Contrôleurs (Products, Recipes)
│   ├── models/            # Modèles (User, Product, Recipe, RecipeIngredient)
│   ├── views/             # Vues ERB + Bootstrap 5
│   ├── helpers/           # Helpers Rails
│   └── assets/            # CSS, JS, images
│
├── config/
│   ├── database.yml       # Configuration PostgreSQL
│   ├── routes.rb          # Routes de l'application
│   └── environments/      # Config par environnement
│
├── db/
│   ├── migrate/           # Migrations (4 tables)
│   ├── schema.rb          # Schéma de la DB
│   └── seeds.rb           # Données de test
│
├── spec/                  # Tests RSpec (recommandé)
├── test/                  # Tests Minitest (par défaut Rails)
│
├── PRD.md                 # Product Requirements Document
├── README.md              # Ce fichier
├── Gemfile                # Dépendances Ruby
└── package.json           # Dépendances JavaScript
