# PRD - Product Requirements Document

## CostChef - SaaS de Calcul de Coût de Revient Matières pour Traiteurs

**Version** : v1.2
**Date** : 04/02/2026
**Statut** : MVP - En développement
**Stack technique** : Rails 7.1 + PostgreSQL + Bootstrap 5

---

## 📑 Table des Matières

1. [Vision et Objectifs](#vision-et-objectifs)
2. [Stack Technique](#stack-technique)
3. [Architecture Base de Données](#architecture-base-de-données)
4. [Personas](#personas)
5. [User Journeys](#user-journeys)
6. [Périmètre Fonctionnel MVP](#périmètre-fonctionnel-mvp)
7. [Règles Métier](#règles-métier)
8. [Validations et Contraintes](#validations-et-contraintes)
9. [Calculs Automatiques](#calculs-automatiques)
10. [Critères de Succès](#critères-de-succès)
11. [Évolutions Futures](#évolutions-futures)

---

## 🎯 Vision et Objectifs

CostChef est une application web SaaS permettant aux traiteurs de calculer précisément le **coût de revient matières** de leurs recettes. L'application remplace les tableurs Excel en offrant un référentiel centralisé, des calculs automatiques et une mise à jour instantanée des coûts lorsque les prix fournisseurs changent.

### Objectifs MVP

- ✅ Permettre la gestion d'un référentiel produits avec prix d'achat
- ✅ Créer des recettes avec calcul automatique du coût matière total
- ✅ **Calculer et afficher le coût au kilogramme (€/kg)** de chaque recette
- ✅ Recalculer automatiquement les coûts quand un prix change
- ✅ Offrir une interface simple et intuitive
- ✅ Réduire de 80% le temps de gestion vs Excel

### Valeur Ajoutée

- **Centralisation** : un seul référentiel produits pour toutes les recettes
- **Automatisation** : recalculs instantanés lors des changements de prix
- **Comparaison** : tri des recettes par coût au kilo
- **Fiabilité** : 0 erreur de calcul (vs Excel)
- **Isolation** : données strictement séparées par utilisateur

---

## 🛠 Stack Technique

### Backend
- **Framework** : Ruby on Rails 7.1
- **Base de données** : PostgreSQL 14+
- **ORM** : Active Record
- **Authentification** : Devise
- **Callbacks** : Pour calculs automatiques

### Frontend
- **Framework CSS** : Bootstrap 5
- **Templates** : ERB (Embedded Ruby)
- **Responsive** : Desktop + Tablette

### Infrastructure
- **Environnements** : Development, Test, Production
- **Hébergement** : TBD
- **Volumétrie estimée** : 10-500 utilisateurs, 500-3000 produits

---

## 🗄 Architecture Base de Données

### Vue d'Ensemble

**4 tables principales** avec **11 index stratégiques** pour des performances optimales.

| Table | Colonnes | Rôle Principal | Volumétrie |
|-------|----------|----------------|------------|
| `users` | 14 | Authentification & Abonnements | 10-500 users |
| `products` | 7 | Référentiel produits | 500-3000 produits |
| `recipes` | 10 | Recettes avec calculs | 200-1500 recettes |
| `recipe_ingredients` | 6 | Jointure + quantités | 1000-20000 lignes |

---

### 📋 Table : USERS

Gestion des utilisateurs, authentification (Devise) et abonnements.

```ruby
# Schema
create_table "users", force: :cascade do |t|
  t.string   "email",                   null: false  # UNIQUE
  t.string   "encrypted_password",      null: false
  t.string   "reset_password_token"                  # UNIQUE
  t.string   "first_name"
  t.string   "last_name"
  t.string   "company_name"
  t.boolean  "subscription_active",     default: false, null: false
  t.date     "subscription_started_at"
  t.date     "subscription_expires_at"
  t.text     "subscription_notes"
  t.boolean  "admin",                   default: false, null: false
  t.datetime "created_at",              null: false
  t.datetime "updated_at",              null: false
end

# Index
add_index "users", ["email"], unique: true
add_index "users", ["reset_password_token"], unique: true
add_index "users", ["subscription_active"]
add_index "users", ["admin"]
```

**Relations** :
- `has_many :products, dependent: :destroy` (CASCADE)
- `has_many :recipes, dependent: :destroy` (CASCADE)

---

### 📦 Table : PRODUCTS

Référentiel des produits avec prix d'achat. Chaque utilisateur a son propre référentiel isolé.

```ruby
# Schema
create_table "products", force: :cascade do |t|
  t.bigint   "user_id",    null: false  # FK → users.id
  t.string   "name",       null: false
  t.decimal  "price",      precision: 8, scale: 2, null: false  # CHECK > 0
  t.string   "unit"                                              # kg, L, pièce
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
end

# Index (CRITIQUES pour isolation données)
add_index "products", ["user_id"]
add_index "products", ["name"]
add_index "products", ["user_id", "name"], unique: true

# Contrainte
# UNIQUE(user_id, name) → Un user ne peut pas avoir 2 produits avec le même nom
```

**Relations** :
- `belongs_to :user`
- `has_many :recipe_ingredients, dependent: :restrict_with_error`

**Comportement ON DELETE** :
- ✅ CASCADE si user supprimé
- ❌ RESTRICT si produit utilisé dans une recette (message d'erreur explicite)

**Callbacks** :
- `after_update` : Recalcule toutes les recettes utilisant ce produit si le prix change

---

### 🍽 Table : RECIPES

Recettes avec calculs en cache pour optimiser les performances.

```ruby
# Schema
create_table "recipes", force: :cascade do |t|
  t.bigint   "user_id",             null: false  # FK → users.id
  t.string   "name",                null: false
  t.text     "description"
  t.decimal  "cached_total_cost",   precision: 10, scale: 2  # €
  t.decimal  "cached_total_weight", precision: 10, scale: 3  # kg
  t.decimal  "cached_cost_per_kg",  precision: 10, scale: 2  # €/kg
  t.datetime "created_at",          null: false
  t.datetime "updated_at",          null: false
end

# Index
add_index "recipes", ["user_id"]
add_index "recipes", ["name"]
add_index "recipes", ["user_id", "name"], unique: true
add_index "recipes", ["cached_cost_per_kg"]  # Pour tri par coût/kg
```

**Relations** :
- `belongs_to :user`
- `has_many :recipe_ingredients, dependent: :destroy`
- `has_many :products, through: :recipe_ingredients`

**Calculs automatiques** (via callbacks) :
```ruby
# Formules
cached_total_cost   = Σ(quantity × product.price)
cached_total_weight = Σ(quantity)
cached_cost_per_kg  = cached_total_cost / cached_total_weight
```

---

### 🔗 Table : RECIPE_INGREDIENTS

Table de jointure entre `recipes` et `products` avec stockage des quantités.

```ruby
# Schema
create_table "recipe_ingredients", force: :cascade do |t|
  t.bigint   "recipe_id",  null: false  # FK → recipes.id
  t.bigint   "product_id", null: false  # FK → products.id
  t.decimal  "quantity",   precision: 10, scale: 3, null: false  # CHECK > 0
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
end

# Index (CRITIQUES pour jointures)
add_index "recipe_ingredients", ["recipe_id"]
add_index "recipe_ingredients", ["product_id"]
add_index "recipe_ingredients", ["recipe_id", "product_id"]
```

**Relations** :
- `belongs_to :recipe`
- `belongs_to :product`

**Comportement ON DELETE** :
- ✅ CASCADE si recipe supprimée
- ❌ RESTRICT si product utilisé

**Callbacks** :
- `after_save`, `after_destroy` : Déclenche le recalcul de la recette

---

### 🔗 Schéma des Relations

```
users (1) ──────────────────> (N) products
  │                                  │
  │                                  │
  │                                  │
  └──────────────────> (N) recipes  │
                            │        │
                            │        │
                            └────────┘
                         (via recipe_ingredients)
```

| De | Vers | Type | ON DELETE |
|----|------|------|-----------|
| `users` | `products` | 1-to-many | CASCADE |
| `users` | `recipes` | 1-to-many | CASCADE |
| `recipes` | `recipe_ingredients` | 1-to-many | CASCADE |
| `products` | `recipe_ingredients` | 1-to-many | RESTRICT |
| `recipes` ↔ `products` | Via `recipe_ingredients` | many-to-many | - |

---

### 🚀 Index de Performance

**11 index stratégiques** pour des temps de réponse < 5ms.

| Table | Index | Type | Objectif |
|-------|-------|------|----------|
| `users` | `email` | UNIQUE | Authentification rapide |
| `users` | `subscription_active` | Simple | Filtrage abonnements |
| `products` | `user_id` | Simple | **Isolation données (CRITIQUE)** |
| `products` | `name` | Simple | Recherche produits |
| `products` | `(user_id, name)` | UNIQUE | Pas de doublons |
| `recipes` | `user_id` | Simple | **Isolation données (CRITIQUE)** |
| `recipes` | `cached_cost_per_kg` | Simple | Tri par coût au kilo |
| `recipe_ingredients` | `recipe_id` | Simple | **Jointure rapide (CRITIQUE)** |
| `recipe_ingredients` | `product_id` | Simple | **Vérif utilisation (CRITIQUE)** |

> ⚠️ **Les index marqués CRITIQUE sont essentiels.** Sans eux, les temps de réponse passeraient de ~1ms à ~200ms.

---

### 📊 Exemple Pratique : Verrine Saumon-Avocat

#### Données dans `recipes`

| Champ | Valeur |
|-------|--------|
| `id` | 1 |
| `user_id` | 2 (Christophe) |
| `name` | Verrine saumon-avocat |
| `description` | Verrine fraîche et élégante pour cocktail |
| `cached_total_cost` | 9.87 € |
| `cached_total_weight` | 0.450 kg |
| `cached_cost_per_kg` | 21.93 €/kg |

#### Données dans `recipe_ingredients` + `products`

| Produit | Prix unitaire | Quantité | Coût ligne |
|---------|--------------|----------|------------|
| Saumon fumé Écosse | 45.00 €/kg | 0.150 kg | 6.75 € |
| Avocat Hass | 8.50 €/kg | 0.200 kg | 1.70 € |
| Crème liquide 35% | 3.20 €/L | 0.050 L | 0.16 € |
| Citron jaune | 4.80 €/kg | 0.050 kg | 0.24 € |
| **TOTAL** | - | **0.450 kg** | **8.85 €** |

#### Formules de Calcul (automatiques via callbacks)

```ruby
# Coût total
(0.150 × 45.00) + (0.200 × 8.50) + (0.050 × 3.20) + (0.050 × 4.80) = 9.87 €

# Poids total
0.150 + 0.200 + 0.050 + 0.050 = 0.450 kg

# Coût au kilo
9.87 / 0.450 = 21.93 €/kg
```

> 💡 Ces calculs sont effectués automatiquement par des callbacks Rails dès qu'un ingrédient est ajouté, modifié ou supprimé, ou qu'un prix de produit change.

---

## 👥 Personas

### Persona 1 : Christophe - Chef Traiteur

- **Âge** : 45 ans
- **Expérience** : 20 ans dans le métier
- **Situation actuelle** : Gère 147 produits et 68 recettes dans Excel
- **Frustrations** : Erreurs de calcul, temps perdu, pas de vue d'ensemble
- **Besoin principal** : Comparer objectivement ses recettes par coût au kilo
- **Objectif** : Optimiser ses marges et standardiser sa production

### Persona 2 : Nadia - Gérante Multi-Sites

- **Âge** : 38 ans
- **Structure** : 3 sites de production
- **Besoin** : Standardisation et contrôle des marges
- **Usage du coût au kilo** : Négocier avec les clients (ex: buffet à 15€/kg)
- **Objectif** : Harmoniser les coûts entre sites

### Persona 3 : Laurent - Jeune Entrepreneur

- **Âge** : 29 ans
- **Statut** : Lancement d'activité de traiteur
- **Approche** : Cherche à optimiser ses marges dès le départ
- **Comportement** : Compare systématiquement le coût au kilo avant de choisir une recette
- **Objectif** : Rentabilité immédiate

---

## 🛤 User Journeys

### Journey 1 : Créer une nouvelle recette

1. Connexion à l'application
2. Clic sur **"Nouvelle Recette"**
3. Saisie du nom (ex: "Verrine saumon-avocat")
4. Saisie de la description (optionnelle)
5. Clic sur **"Ajouter un ingrédient"**
6. Sélection du produit dans le référentiel (ex: Saumon fumé)
7. Saisie de la quantité (ex: 0.150 kg)
8. Répétition des étapes 5-7 pour tous les ingrédients
9. **Le système calcule automatiquement le poids total**
10. **Le système affiche le coût total ET le coût au kilo (€/kg)**
11. Sauvegarde de la recette
12. ✅ **La recette est créée et apparaît dans la liste avec son coût au kilo**

---

### Journey 2 : Mettre à jour un prix fournisseur

1. Accès au référentiel produits
2. Recherche du produit (ex: "Saumon fumé")
3. Modification du prix (45.00€ → 47.00€)
4. Sauvegarde
5. **🔄 Toutes les recettes utilisant ce produit recalculent automatiquement :**
   - Coût total
   - Coût au kilo
6. Notification des recettes impactées (ex: "5 recettes mises à jour")
7. ✅ **L'utilisateur peut consulter les nouvelles valeurs immédiatement**

---

### Journey 3 : Comparer les recettes par coût au kilo

1. Accès à la liste des recettes
2. Clic sur **"Trier par coût au kilo"**
3. Les recettes s'affichent triées (de la moins chère à la plus chère)
4. L'utilisateur identifie les recettes les plus rentables
5. ✅ **Décision éclairée pour la carte ou les devis clients**

---

## 🎯 Périmètre Fonctionnel MVP

### Module 1 : Authentification

- ✅ Inscription via lien sécurisé généré par l'admin
- ✅ Connexion email/mot de passe (Devise)
- ✅ Gestion des abonnements (actif/inactif)
- ✅ Isolation stricte des données par utilisateur
- ✅ Rôle administrateur (gestion des utilisateurs)

---

### Module 2 : Référentiel Produits

#### CRUD Complet
- ✅ **Create** : Ajouter un nouveau produit (nom, prix, unité)
- ✅ **Read** : Lister tous les produits de l'utilisateur
- ✅ **Update** : Modifier un produit (déclenche recalcul des recettes)
- ✅ **Delete** : Supprimer un produit (bloqué si utilisé dans une recette)

#### Fonctionnalités
- ✅ Recherche par nom
- ✅ Tri (nom, prix, date de création)
- ✅ Validation : nom unique par utilisateur
- ✅ Validation : prix > 0
- ✅ Message d'erreur explicite si suppression impossible

#### Interface
- ✅ Liste des produits avec colonnes : Nom, Prix, Unité, Actions
- ✅ Formulaire d'ajout/édition
- ✅ Boutons : Éditer, Supprimer

---

### Module 3 : Gestion des Recettes

#### CRUD Complet
- ✅ **Create** : Créer une nouvelle recette
- ✅ **Read** : Lister toutes les recettes de l'utilisateur
- ✅ **Update** : Modifier une recette (nom, description, ingrédients)
- ✅ **Delete** : Supprimer une recette (supprime aussi les ingrédients)

#### Gestion des Ingrédients
- ✅ Ajouter un ingrédient à une recette (sélection produit + quantité)
- ✅ Modifier la quantité d'un ingrédient
- ✅ Supprimer un ingrédient
- ✅ Validation : quantité > 0
- ✅ Validation : au moins 1 ingrédient par recette

#### Calculs Automatiques
- ✅ **Coût total** : Σ(quantité × prix unitaire)
- ✅ **Poids total** : Σ(quantité) en kg
- ✅ **Coût au kilogramme** : Coût total / Poids total (€/kg)
- ✅ Affichage en temps réel
- ✅ Recalcul automatique si modification d'un ingrédient
- ✅ Recalcul automatique si changement de prix d'un produit

#### Fonctionnalités Avancées
- ✅ **Fonction "Dupliquer une recette"** (Should Have)
- ✅ **Tri des recettes par coût au kilo** (Should Have)
- ✅ Recherche par nom

#### Interface
- ✅ Liste des recettes avec colonnes :
  - Nom
  - Description (tronquée)
  - Coût total (€)
  - Poids total (kg)
  - **Coût au kilo (€/kg)** ← Mise en avant
  - Actions
- ✅ Vue détaillée d'une recette :
  - Informations générales
  - Liste des ingrédients avec quantités
  - Calculs (coût total, poids total, coût au kilo)
  - Bouton "Dupliquer"
- ✅ Formulaire d'ajout/édition avec gestion dynamique des ingrédients

---

## 📐 Règles Métier

### Calculs Automatiques

#### Coût total d'une recette
```ruby
# Formule
Coût total = Σ (quantité × prix unitaire) pour chaque ingrédient

# Exemple
(0.150 × 45.00) + (0.200 × 8.50) + (0.050 × 3.20) + (0.050 × 4.80) = 9.87 €
```

#### Poids total
```ruby
# Formule
Poids total = Σ (quantité) pour chaque ingrédient (en kg)

# Exemple
0.150 + 0.200 + 0.050 + 0.050 = 0.450 kg
```

#### Coût au kilo
```ruby
# Formule
Coût au kilo = Coût total / Poids total (arrondi à 2 décimales)

# Exemple
9.87 / 0.450 = 21.93 €/kg
```

#### Déclencheurs de Recalcul
- ✅ Ajout d'un ingrédient à une recette
- ✅ Modification de la quantité d'un ingrédient
- ✅ Suppression d'un ingrédient
- ✅ **Modification du prix d'un produit** → recalcul de TOUTES les recettes utilisant ce produit
- ✅ Calculs effectués côté serveur (callbacks Rails)

#### Précision
- **Prix** : 2 décimales (ex: 45.00 €)
- **Quantités** : 3 décimales (ex: 0.150 kg)
- **Coûts** : 2 décimales (ex: 21.93 €/kg)

---

### Validation des Données

#### Produits
- ✅ **Prix** : doit être > 0
- ✅ **Nom** : unique par utilisateur (contrainte DB)
- ✅ **Nom** : obligatoire (NOT NULL)
- ✅ Message d'erreur si suppression d'un produit utilisé dans une recette

#### Recettes
- ✅ **Nom** : unique par utilisateur (contrainte DB)
- ✅ **Nom** : obligatoire (NOT NULL)
- ✅ **Ingrédients** : au moins 1 ingrédient par recette

#### Ingrédients (recipe_ingredients)
- ✅ **Quantité** : doit être > 0 (contrainte CHECK)
- ✅ **Quantité** : obligatoire (NOT NULL)

---

### Règles de Suppression

#### Suppression d'un User
- ✅ **CASCADE** : Supprime automatiquement tous ses `products` et `recipes`
- ✅ Les `recipe_ingredients` liés sont aussi supprimés (via CASCADE sur recipes)

#### Suppression d'un Product
- ❌ **RESTRICT** : Impossible si le produit est utilisé dans au moins 1 recette
- ✅ Message d'erreur explicite : _"Ce produit est utilisé dans X recette(s). Veuillez d'abord le retirer des recettes concernées."_
- ✅ Liste des recettes utilisant le produit (optionnel mais recommandé)

#### Suppression d'une Recipe
- ✅ **CASCADE** : Supprime automatiquement tous ses `recipe_ingredients`

#### Suppression d'un Recipe_Ingredient
- ✅ Suppression simple (pas de dépendances)
- ✅ Déclenche le recalcul de la recette (callback)

---

## ⚙️ Calculs Automatiques

### Implémentation avec Callbacks Rails

#### Modèle : Recipe

```ruby
class Recipe < ApplicationRecord
  belongs_to :user
  has_many :recipe_ingredients, dependent: :destroy
  has_many :products, through: :recipe_ingredients

  # Callbacks
  after_save :recalculate_costs
  after_touch :recalculate_costs

  private

  def recalculate_costs
    # Coût total
    self.cached_total_cost = recipe_ingredients.joins(:product)
                                               .sum('recipe_ingredients.quantity * products.price')

    # Poids total
    self.cached_total_weight = recipe_ingredients.sum(:quantity)

    # Coût au kilo
    if cached_total_weight > 0
      self.cached_cost_per_kg = cached_total_cost / cached_total_weight
    else
      self.cached_cost_per_kg = 0
    end

    # Sauvegarde sans déclencher de nouveau callback
    save(validate: false) if changed?
  end
end
```

---

#### Modèle : RecipeIngredient

```ruby
class RecipeIngredient < ApplicationRecord
  belongs_to :recipe
  belongs_to :product

  # Callbacks
  after_save :trigger_recipe_recalculation
  after_destroy :trigger_recipe_recalculation

  private

  def trigger_recipe_recalculation
    recipe.recalculate_costs
  end
end
```

---

#### Modèle : Product

```ruby
class Product < ApplicationRecord
  belongs_to :user
  has_many :recipe_ingredients, dependent: :restrict_with_error
  has_many :recipes, through: :recipe_ingredients

  # Callbacks
  after_update :recalculate_affected_recipes, if: :price_changed?

  private

  def recalculate_affected_recipes
    recipes.each(&:recalculate_costs)
  end
end
```

---

## ✅ Validations et Contraintes

### Niveau Base de Données (PostgreSQL)

```sql
-- Contraintes CHECK
ALTER TABLE products ADD CONSTRAINT price_positive CHECK (price > 0);
ALTER TABLE recipe_ingredients ADD CONSTRAINT quantity_positive CHECK (quantity > 0);

-- Contraintes UNIQUE
ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE (email);
ALTER TABLE products ADD CONSTRAINT unique_user_product UNIQUE (user_id, name);
ALTER TABLE recipes ADD CONSTRAINT unique_user_recipe UNIQUE (user_id, name);

-- Contraintes NOT NULL
-- (déjà définies dans les schemas ci-dessus)
```

---

### Niveau Modèle Rails (ActiveRecord)

```ruby
# User
validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
validates :encrypted_password, presence: true

# Product
validates :name, presence: true, uniqueness: { scope: :user_id }
validates :price, presence: true, numericality: { greater_than: 0 }
validates :user, presence: true

# Recipe
validates :name, presence: true, uniqueness: { scope: :user_id }
validates :user, presence: true
validate :must_have_at_least_one_ingredient, on: :update

# RecipeIngredient
validates :quantity, presence: true, numericality: { greater_than: 0 }
validates :recipe, presence: true
validates :product, presence: true
```

---

## 📊 Critères de Succès

### Objectifs à 3 mois post-lancement

#### Adoption
- ✅ 80% des recettes Excel migrées dans CostChef
- ✅ Utilisation hebdomadaire : 2+ connexions par utilisateur actif
- ✅ Taux d'abandon < 10%

#### Performance
- ✅ Temps de réponse < 200ms pour 95% des requêtes
- ✅ **0 erreur de calcul sur les coûts au kilo**
- ✅ Disponibilité : 99.5%

#### Productivité
- ✅ Réduction de 80% du temps de calcul vs Excel
- ✅ **5x plus rapide pour comparer les recettes par coût au kilo**
- ✅ 0 incohérence de prix entre recettes

#### Satisfaction
- ✅ NPS (Net Promoter Score) > 40
- ✅ < 5% de tickets support liés à des bugs
- ✅ Feedback positif sur le calcul automatique du coût au kilo

---

## 🚀 Évolutions Futures

### Phase 2 : Collaboration (Q2 2026)
- Multi-utilisateurs par entreprise
- Rôles et permissions (admin, chef, comptable)
- Partage de recettes entre collègues
- Commentaires sur les recettes

### Phase 3 : Calcul de Marge (Q3 2026)
- Saisie des prix de vente
- Calcul automatique des marges (% et €)
- Suggestions de prix de vente basées sur le coût au kilo cible
- Dashboard de rentabilité

### Phase 4 : Import/Export (Q4 2026)
- Import depuis Excel (mapping intelligent)
- Export PDF/Excel
- Export comparatif avec coût au kilo
- API REST pour intégrations tierces

### Phase 5 : Intégrations (Q1 2027)
- Connexion aux logiciels de caisse
- Synchronisation avec logiciels de gestion stocks
- Import automatique des prix fournisseurs (API)

### Phase 6 : Intelligence Artificielle (Q2 2027)
- Alertes si coût au kilo d'une catégorie dépasse les moyennes du marché
- Benchmarks de coût au kilo par type de recette
- Suggestions d'optimisation des recettes (ingrédients alternatifs)
- Prévisions de coûts basées sur l'historique

---

## 📋 Priorisation MoSCoW

### ✅ Must Have (MVP)
- Authentification avec gestion d'abonnements
- CRUD Produits avec validation
- CRUD Recettes avec ingrédients
- **Calcul automatique du coût au kilo**
- **Recalcul automatique si prix change**
- Isolation des données par utilisateur
- Interface responsive (desktop + tablette)

### 🟡 Should Have (MVP si temps)
- Fonction "Dupliquer une recette"
- **Tri des recettes par coût au kilo**
- Recherche avancée (filtres)
- Dashboard avec statistiques

### 🔵 Could Have (Post-MVP)
- Export PDF/Excel
- Comparaison de recettes par coût au kilo (vue côte à côte)
- Historique des modifications de prix
- Notifications email

### ⚪️ Won't Have (Hors périmètre MVP)
- Application mobile native
- Multi-utilisateurs (Phase 2)
- Calcul de marge (Phase 3)
- Intégrations externes (Phase 5)

---

## 📖 Glossaire

| Terme | Définition |
|-------|------------|
| **Coût de revient matières** | Somme des coûts des ingrédients d'une recette |
| **Coût au kilo (€/kg)** | Coût total divisé par le poids total de la recette |
| **Référentiel produits** | Base de données centralisée des produits et prix |
| **Recette** | Ensemble d'ingrédients avec leurs quantités |
| **Ingrédient** | Produit du référentiel utilisé dans une recette |
| **Recalcul automatique** | Mise à jour des coûts sans intervention manuelle |
| **Isolation des données** | Chaque utilisateur voit uniquement ses données |
| **Cache** | Stockage des calculs (cached_*) pour améliorer les performances |
| **Index** | Structure DB pour accélérer les recherches |
| **Callback** | Code Rails exécuté automatiquement après une action |
| **CASCADE** | Suppression automatique des enregistrements liés |
| **RESTRICT** | Bloque la suppression si l'enregistrement est utilisé |

---

## 🔧 Notes Techniques pour Claude Code

### Priorités de Développement
1. **Setup initial** : Rails 7.1 + PostgreSQL + Devise
2. **Migrations** : Créer les 4 tables avec contraintes et index
3. **Modèles** : Implémenter les relations et callbacks
4. **Contrôleurs** : CRUD complet pour Products et Recipes
5. **Vues** : Interface Bootstrap 5 responsive
6. **Tests** : Validations et calculs automatiques

### Points d'Attention
- ⚠️ **Ne jamais oublier les index sur user_id** (isolation données)
- ⚠️ **Callbacks** : Attention aux boucles infinies (utiliser `save(validate: false)`)
- ⚠️ **Division par zéro** : Vérifier `cached_total_weight > 0` avant calcul du coût/kg
- ⚠️ **Dependent: :restrict_with_error** : Pour empêcher suppression de produits utilisés
- ⚠️ **Précision** : Utiliser `DECIMAL` (pas `FLOAT`) pour les calculs financiers

### Commandes Rails Utiles
```bash
# Générer les migrations
rails generate migration CreateUsers
rails generate migration CreateProducts
rails generate migration CreateRecipes
rails generate migration CreateRecipeIngredients

# Lancer les migrations
rails db:migrate

# Seeds (données de test)
rails db:seed

# Console Rails (debug)
rails console
```

---

**FIN DU PRD - Version 1.2**
