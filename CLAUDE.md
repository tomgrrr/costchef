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
- **ProductPurchase** — Price history. Purchase units: `[kg, g, l, cl, ml, piece]`. `active` boolean filters obsolete prices.
- **Recipe** — Cost calculations with cached metrics (`cached_total_cost`, `cached_total_weight`, `cached_cost_per_kg`, `cached_total_cost_with_loss`). `cooking_loss_percentage` (0-100). `sellable_as_component` controls sub-recipe eligibility.
- **RecipeComponent** — Polymorphic join (`component_type`: Product or Recipe). **Max 1 level of sub-recipe depth.**
- **Supplier** — Linked to ProductPurchases. Soft-delete via `active` flag.
- **TraySize** — Optional recipe association. Nullified on delete.
- **DailySpecial** — Independent history (meat/fish/side).
- **Invitation** — Signup by invitation only.

Key relationships:
- User `has_many` Products, Recipes, Suppliers, TraySizes, DailySpecials (cascade delete)
- Product `has_many` ProductPurchases (cascade), RecipeComponents (restrict delete if in use)
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

0. `Units::Converter` — Source unique de vérité pour conversions d'unités vers kg.
   Expose `to_kg(quantity, unit, product:)` et `to_display_unit(quantity_kg, unit, product:)`.
   Règles : 1L=1kg, piece→unit_weight_kg, unités valides: kg/g/l/cl/ml/piece.
1. `ProductPurchases::PricePerKgCalculator.call(purchase)` — Calcule price_per_kg. Délègue conversion à Units::Converter.
2. `Products::AvgPriceRecalculator.call(product)` — Moyenne pondérée des achats actifs.
3. `Recipes::Recalculator.call(recipe)` — Recalcule les 4 champs cached_*.
4. `Recalculations::Dispatcher` — Orchestre la cascade et propage aux recettes parentes.

Test each service with a dedicated RSpec before integrating into controllers.

### Deletion Rules

- **Product:** Block deletion if used in a RecipeComponent.
- **Supplier:** Block deletion if ProductPurchases exist (unless force=true).
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

### Test Suite (93 specs, 0 failures)

**Setup:**
- `spec/factories.rb` — Single file with all factories (user, supplier, product, product_purchase, recipe, recipe_component, invitation).
- `spec/support/devise.rb` — Includes `Devise::Test::IntegrationHelpers` for request specs.
- `spec/support/database_cleaner.rb` + `spec/support/factory_bot.rb` — Standard config.

**Conventions:**
- Request specs use `sign_in user` (Devise helper), `before(:each)` only (no `before(:all)`).
- Use `let!` (eager) for invitation in POST specs where `expect { }.to change(User, :count)` — avoids counting the admin user created by the invitation factory.
- Product factory has a uniqueness constraint on `name` per user — use distinct names when creating multiple products (not `create_list`).

**Spec files:**
- `spec/services/` — 5 service specs (Units::Converter, PricePerKgCalculator, AvgPriceRecalculator, Recalculator, Dispatcher). 46 examples.
- `spec/requests/pages_spec.rb` — 8 examples. Covers `GET /` (auth, subscription gate, counters) + `GET /subscription_required`.
- `spec/requests/signups_spec.rb` — 17 examples. Covers `GET /signup` (no token, invalid, expired, used, valid) + `POST /signup` (success, short password, mismatch, expired token).
- `spec/requests/admin/invitations_spec.rb` — 13 examples. Covers index/new/create with auth (non-connected, user, admin) + email validation + `have_enqueued_mail`.
- `spec/requests/admin/users_spec.rb` — 9 examples. Covers index (auth, user list, subscription badges) + update (subscription_active, subscription_notes, non-admin blocked).
