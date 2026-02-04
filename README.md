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

📋 Prérequis
Avant de commencer, assurez-vous d'avoir installé :

Ruby 3.2 ou supérieur
Rails 7.1 ou supérieur
PostgreSQL 14 ou supérieur
Node.js 18+ (pour les assets)
Yarn ou npm

Vérifier les versions
bashruby -v
# ruby 3.2.0 ou supérieur

rails -v
# Rails 7.1.0 ou supérieur

psql --version
# psql (PostgreSQL) 14.0 ou supérieur

🔧 Installation
1. Cloner le repository
bashgit clone https://github.com/votre-username/costchef.git
cd costchef
2. Installer les dépendances
bash# Gems Ruby
bundle install

# Packages JavaScript
yarn install
# ou
npm install
3. Configuration de la base de données
Créez un fichier .env à la racine du projet (copiez .env.example) :
bashcp .env.example .env
Éditez .env avec vos credentials PostgreSQL :
envDATABASE_USERNAME=votre_user_postgres
DATABASE_PASSWORD=votre_mot_de_passe
DATABASE_HOST=localhost
DATABASE_PORT=5432
4. Créer et initialiser la base de données
bash# Créer les bases (development + test)
rails db:create

# Lancer les migrations
rails db:migrate

# (Optionnel) Charger les données de test
rails db:seed
5. Lancer le serveur
bash# Serveur Rails
rails server

# Ou avec foreman (si configuré)
foreman start -f Procfile.dev
L'application sera accessible sur http://localhost:3000

🎮 Utilisation
1️⃣ Créer un compte

Accédez à /users/sign_up (si inscription publique activée)
Ou demandez à un admin de générer un lien d'inscription sécurisé

2️⃣ Ajouter vos produits
1. Cliquez sur "Produits" dans le menu
2. Cliquez sur "Nouveau Produit"
3. Remplissez : Nom, Prix unitaire, Unité (kg, L, pièce)
4. Sauvegardez
3️⃣ Créer une recette
1. Cliquez sur "Recettes" dans le menu
2. Cliquez sur "Nouvelle Recette"
3. Remplissez : Nom, Description
4. Ajoutez des ingrédients :
   - Sélectionnez un produit
   - Indiquez la quantité (ex: 0.150 kg)
   - Cliquez sur "Ajouter"
5. Les calculs se font automatiquement :
   ✓ Coût total
   ✓ Poids total
   ✓ Coût au kilo (€/kg)
6. Sauvegardez
4️⃣ Mettre à jour un prix
1. Allez dans "Produits"
2. Cliquez sur "Éditer" pour le produit concerné
3. Modifiez le prix (ex: 45€ → 47€)
4. Sauvegardez
5. ✨ Toutes les recettes utilisant ce produit se recalculent automatiquement !
5️⃣ Comparer vos recettes
1. Allez dans "Recettes"
2. Cliquez sur "Trier par coût au kilo"
3. Visualisez vos recettes de la moins chère à la plus chère
4. Optimisez votre carte en fonction !

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

🧪 Tests
Lancer les tests
bash# Avec RSpec (recommandé)
bundle exec rspec

# Avec Minitest (Rails par défaut)
rails test

# Tests unitaires seulement
rails test:models

# Tests des contrôleurs
rails test:controllers
Couverture de code
bash# Avec SimpleCov
COVERAGE=true bundle exec rspec

# Ouvrir le rapport
open coverage/index.html

🔒 Sécurité
Authentification

Mots de passe chiffrés avec bcrypt (via Devise)
Tokens de réinitialisation sécurisés pour l'envoi et la création de nouveaux comptes
Protection CSRF activée

Isolation des données

Scope automatique : chaque utilisateur ne voit que ses données
Index sur user_id pour des performances optimales
Contraintes UNIQUE sur (user_id, name) pour éviter les doublons

Variables d'environnement

Credentials sensibles dans .env (gitignored)
Rails Credentials pour la production
