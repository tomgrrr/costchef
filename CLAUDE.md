# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CostChef is a Ruby on Rails SaaS application for catering businesses to calculate recipe material costs. It replaces Excel spreadsheets with an automated cost management system.

**Tech Stack:** Rails 7.1 + Ruby 3.3.5 + PostgreSQL + Bootstrap 5 + Stimulus/Turbo (Hotwire)

## Development Commands

```bash
# Start development server (web + CSS watcher via foreman)
bin/dev

# Setup environment
bin/setup

# Database
bin/rails db:prepare      # Create + migrate
bin/rails db:migrate      # Run migrations
bin/rails db:seed         # Load seed data

# Testing
bundle exec rspec         # Run test suite

# Code quality
rubocop -a                # Lint and auto-fix Ruby

# CSS compilation
yarn build:css            # One-time build
yarn watch:css            # Watch mode (included in bin/dev)

# Console
bin/rails console         # Interactive Ruby shell
```

**Seed users:** `admin@costchef.fr`, `christophe@traiteur.fr`, `laurent@nouveau.fr` (all `password123`)

## Architecture

### Data Model (Multi-tenant with user isolation)

- **User** — Owns everything. `markup_coefficient` (default 1.0). Auth via Devise.
- **Product** — Ingredient library. `base_unit` among `[kg, l, piece]`. If `piece`, `unit_weight_kg` is required.
- **ProductPurchase** — Price history. Purchase units: `Units::VALID_UNITS`. `package_quantity_kg` and `price_per_kg` are nullable (calculated by service). `active` boolean filters obsolete prices.
- **Recipe** — Cost calculations with cached metrics (`cached_total_cost`, `cached_total_weight`, `cached_cost_per_kg`, `cached_raw_weight`). `cooking_loss_percentage` (0-100). `sellable_as_component` controls sub-recipe eligibility.
- **RecipeComponent** — Polymorphic join (`component_type`: Product or Recipe). `quantity_unit` validated against `Units::VALID_UNITS`. **Max 1 level of sub-recipe depth.**
- **Supplier** — Linked to ProductPurchases. Soft-delete via `active` flag.
- **TraySize** — Optional recipe association. Nullified on delete.
- **DailySpecial** — Independent history (meat/fish/side). Class methods `meat_average`, `fish_average`, `side_average` (scoped via `user.daily_specials`).
- **Invitation** — Signup by invitation only.

Key relationships:
- User `has_many` Products, Recipes, Suppliers, TraySizes, DailySpecials (cascade delete)
- Product `has_many` ProductPurchases (cascade), RecipeComponents (restrict delete if in use). Unique index on `[user_id, name]`.
- Supplier `has_many` ProductPurchases (restrict delete)
- Recipe `has_many` RecipeComponents, Products (through)
- TraySize `has_many` Recipes (nullify on delete)

### Coding Rules

- **Short methods:** Max 10 lines per method. Decompose into private sub-methods.
- **Single Responsibility (SRP):** One service = one action.
- **Zero ActiveRecord callbacks** for business logic/calculations — everything goes through Services.
- **Fail Fast:** Validate inputs at service entry, raise explicit errors.

### Service Layer & Calculation Cascade

Convention: `app/services/{domain}/{action}.rb` → `Domain::ActionName.call(obj)`

Services (5 total):

0. `Units` module (`app/services/units.rb`) — Définit `VALID_UNITS = %w[kg g l cl ml piece]`.
   `Units::Converter` (`app/services/units/converter.rb`) — Source unique de vérité pour conversions d'unités vers kg.
   Expose `to_kg(quantity, unit, product:)` et `to_display_unit(quantity_kg, unit, product:)`.
   Règles : 1L=1kg, piece→unit_weight_kg.
1. `ProductPurchases::PricePerKgCalculator.call(purchase)` — Calcule price_per_kg. Délègue conversion à Units::Converter.
2. `Products::AvgPriceRecalculator.call(product)` — Moyenne pondérée des achats actifs.
3. `Recipes::Recalculator.call(recipe)` — Recalcule les 4 champs cached_*.
4. `Recalculations::Dispatcher` — Orchestre la cascade et propage aux recettes parentes.

Test each service with a dedicated RSpec before integrating into controllers.

### Deletion Rules

- **Product:** Block deletion if used in a RecipeComponent.
- **Supplier:** Block deletion if ProductPurchases exist (unless force=true). `force_destroy!` uses `delete_all` (direct SQL, no callbacks per PRD D15).
- **TraySize:** Nullify `tray_size_id` in recipes (no recipe destruction).

### Frontend Architecture

- **CSS:** Sass compiled via `cssbundling-rails` → `app/assets/builds/application.css`
- **JS:** Stimulus controllers in `app/javascript/controllers/`
- **Views:** ERB templates with Bootstrap 5 components
- **Entry point:** `app/assets/stylesheets/application.bootstrap.scss`

### Auth & Access

- **Devise** for authentication, signup by invitation only.
- **Subscription gate** (`ensure_subscription!`) in `ApplicationController` — redirects to `/subscription_required` if `subscription_active == false`.
- **Admin namespace** (`/admin`) inherits from `Admin::BaseController` with `require_admin!` check + `skip_before_action :ensure_subscription!`.
- **SignupsController** — skips both `authenticate_user!` and `ensure_subscription!`. Validates invitation token (`valid_for_signup?`: not used + not expired). On success: creates user, calls `invitation.mark_as_used!`, auto sign-in.
- **PagesController** — `home` (root, requires auth + subscription), `subscription_required` (requires auth only, `skip_before_action :ensure_subscription!`).

### Invitation System

- **Model:** `Invitation` belongs_to `created_by_admin` (User). Fields: `email`, `token`, `expires_at`, `used_at`. Auto-generates token + sets 7-day expiration via `before_validation` callbacks. Validates email uniqueness + not already registered as User.
- **Lifecycle:** `valid_for_signup?` → `used_at.nil? && expires_at > Time.current`. `mark_as_used!` → sets `used_at` to now. `status` returns `:pending`, `:expired`, or `:used`.
- **Admin flow:** `Admin::InvitationsController` — index/new/create. On create, sends `InvitationMailer.invite_user(@invitation).deliver_later`.
- **Signup flow:** `GET /signup?token=xxx` → form. `POST /signup` with `token` param + `user[password]` + `user[password_confirmation]`.

### Test Suite (360 specs, 0 failures)

**Setup:**
- `spec/factories.rb` — Single file with all factories (user, supplier, product, product_purchase, recipe, recipe_component, daily_special, invitation, tray_size).
- `spec/support/devise.rb` — Includes `Devise::Test::IntegrationHelpers` for request specs.
- `spec/support/database_cleaner.rb` + `spec/support/factory_bot.rb` — Standard config.

**Conventions:**
- Request specs use `sign_in user` (Devise helper), `before(:each)` only (no `before(:all)`).
- Use `let!` (eager) for invitation in POST specs where `expect { }.to change(User, :count)` — avoids counting the admin user created by the invitation factory.
- Product factory has a uniqueness constraint on `name` per user — use distinct names when creating multiple products (not `create_list`).

**Spec files:**
- `spec/services/` — 5 service specs (Units::Converter, PricePerKgCalculator, AvgPriceRecalculator, Recalculator, Dispatcher). 46 examples.
- `spec/models/correctifs_spec.rb` — 12 examples. RecipeComponent quantity_unit, ProductPurchase calculated fields + package_unit, Supplier#force_destroy!, DailySpecial averages.
- `spec/models/product_spec.rb` — 23 examples. Validations (name, base_unit, avg_price_per_kg), D6 unit_weight_kg, méthodes, defaults.
- `spec/models/product_purchase_spec.rb` — 22 examples. Validations, supplier_belongs_to_same_user, scopes, toggle_active!, defaults.
- `spec/models/recipe_spec.rb` — 36 examples. Validations (name, description, cooking_loss, tray_size), defaults, scopes, méthodes métier, calculs.
- `spec/models/recipe_component_spec.rb` — 39 examples. Validations base (quantity, unit, type, unicité D9), validations métier (sellable, max_depth, self/circular ref, same_user), méthodes instance.
- `spec/requests/pages_spec.rb` — 8 examples. GET / (auth, subscription gate, counters) + GET /subscription_required.
- `spec/requests/signups_spec.rb` — 17 examples. GET /signup + POST /signup.
- `spec/requests/products_spec.rb` — 21 examples. Index (auth, search), POST, PATCH, DELETE.
- `spec/requests/suppliers_spec.rb` — 27 examples. Index, POST, PATCH, activate/deactivate, DELETE, force destroy, isolation.
- `spec/requests/product_purchases_spec.rb` — 21 examples. POST, PATCH, DELETE, toggle_active avec turbo_stream.
- `spec/requests/recipes_spec.rb` — 38 examples. Index (auth, search), show, new, create, edit, update, destroy, duplicate.
- `spec/requests/recipe_components_spec.rb` — 28 examples. POST (kg, g, sous-recette), PATCH, DELETE avec turbo_stream + isolation.
- `spec/requests/admin/invitations_spec.rb` — 13 examples. Index/new/create avec auth + email validation + have_enqueued_mail.
- `spec/requests/admin/users_spec.rb` — 9 examples. Index + update (subscription_active, notes, non-admin blocked).
