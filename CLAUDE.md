# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CostChef is a Ruby on Rails SaaS application for catering businesses to calculate recipe material costs. It replaces Excel spreadsheets with an automated cost management system.

**Tech Stack:** Rails 7.1.6 + Ruby 3.3.5 + PostgreSQL + Bootstrap 5 + Stimulus/Turbo (Hotwire)

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

- **User** — Owns everything. `markup_coefficient` (default 1.0, min 0.1). `price_variability_threshold` (default 10.0, 0-100, CV% threshold for price alerts). Auth via Devise (`:lockable`, `:timeoutable`). Fields: `first_name`, `last_name`, `company_name`, `admin` (boolean), `subscription_active/started_at/expires_at/notes`, `failed_attempts`, `locked_at`, `unlock_token`.
- **Product** — Ingredient library. `base_unit` among `[kg, l, piece]`. If `piece`, `unit_weight_kg` is required (> 0); must be absent otherwise. `avg_price_per_kg` (default 0, >= 0). Methods: `piece_unit?`, `used_in_recipes?`, `recipes_count`, `simple_avg_price_per_kg` (arithmetic mean of active purchases' `price_per_kg`, rounded to 2 decimals), `high_variability?` (delegates to `Products::VariabilityCalculator`, returns true if CV% > user's `price_variability_threshold`).
- **ProductPurchase** — Price history. `package_unit` restricted to units compatible with product's `base_unit` (via `Units.allowed_for`). `package_quantity_kg` and `price_per_kg` are calculated by `PricePerKgCalculator` (via `before_validation`). `active` boolean filters obsolete prices. Scopes: `active`, `inactive`. Method: `toggle_active!`. Custom validations: `supplier_belongs_to_same_user`, `package_unit_matches_base_unit`.
- **Recipe** — Cost calculations with 4 cached metrics (`cached_total_cost`, `cached_total_weight`, `cached_cost_per_kg`, `cached_raw_weight`). `cooking_loss_percentage` (0-100, default 0). `sellable_as_component` controls sub-recipe eligibility. `has_tray` + `tray_size_id` for packaging. `sold_by_unit` (boolean, default false) + `unit_reference_weight_kg` (decimal, nullable) for unit pricing. Scopes: `usable_as_subrecipe`, `by_cost_per_kg`, `by_cost_per_kg_desc`. Methods: `subrecipe?`, `used_as_subrecipe?`, `parent_recipes_count`, `has_subrecipes?`, `product_components`, `subrecipe_components`, `calculated_*` (4 calculation methods), `suggested_selling_price`, `unit_cost` (cost_per_kg × unit_weight, nil if N/A), `unit_selling_price` (selling_price × unit_weight, nil if N/A), `demotion_alert_message` (returns warning string when `sellable_as_component` changes true→false and parent recipes exist, nil otherwise). Validations: `tray_size_consistency`, `tray_size_belongs_to_same_user`, `subrecipe_cannot_have_tray`, `unit_reference_weight_consistency` (weight required and > 0 when sold_by_unit), `subrecipe_cannot_be_sold_by_unit`.
- **RecipeComponent** — Polymorphic join (`component_type`: Product or Recipe). `quantity_kg` (> 0) + `quantity_unit` validated against `Units::VALID_UNITS`. Unique constraint on `[parent_recipe_id, component_type, component_id]`. **Max 1 level of sub-recipe depth.** Validations: `validate_subrecipe_is_sellable`, `validate_max_depth`, `validate_no_self_reference`, `validate_no_circular_reference`, `validate_same_user`. Methods: `recipe_component?`, `product_component?`, `line_cost`.
- **Supplier** — Linked to ProductPurchases. Soft-delete via `active` flag. Scopes: `active`, `inactive`. Methods: `deactivate!`, `activate!`, `has_purchases?`, `force_destroy!` (returns impacted product_ids).
- **TraySize** — Optional recipe association. `before_destroy` nullifies `tray_size_id` and sets `has_tray=false` on related recipes. Method: `recipes_count`.
- **DailySpecial** — Independent history. `CATEGORIES = %w[meat fish side]`. Scopes: `meats`, `fishes`, `sides`. Class methods: `average_cost_per_kg_for(category)`, `meat_average`, `fish_average`, `side_average`.
- **Invitation** — Signup by invitation only. Auto-generates `token` (SecureRandom) + sets 7-day `expires_at` via `before_validation` on create. Scopes: `pending`, `expired`, `used`. Methods: `valid_for_signup?`, `mark_as_used!`, `status` (returns `:pending`, `:expired`, or `:used`). Validates email uniqueness + not already registered.

Key relationships:
- User `has_many` Products, Recipes, Suppliers, TraySizes, DailySpecials (cascade delete), Invitations (nullify)
- Product `has_many` ProductPurchases (cascade), RecipeComponents (restrict delete if in use). Unique index on `[user_id, name]`.
- Supplier `has_many` ProductPurchases (restrict delete)
- Recipe `has_many` RecipeComponents (via `parent_recipe_id`), `parent_recipe_components` (as component, restrict), Products (through)
- TraySize `has_many` Recipes (nullify on delete)

### Coding Rules

- **Short methods:** Max 10 lines per method. Decompose into private sub-methods.
- **Single Responsibility (SRP):** One service = one action.
- **Zero ActiveRecord callbacks** for business logic/calculations — everything goes through Services. Exception: `ProductPurchase#before_validation` calls `PricePerKgCalculator` for derived field calculation.
- **Fail Fast:** Validate inputs at service entry, raise explicit errors.

### Service Layer & Calculation Cascade

Convention: `app/services/{domain}/{action}.rb` → `Domain::ActionName.call(obj)`

Services (7 total):

0. `Units` module (`app/services/units.rb`) — Defines `VALID_UNITS = %w[kg g l cl ml piece]`.
   `ALLOWED_PURCHASE_UNITS` maps base_unit to allowed package_units: `kg→[kg,g]`, `l→[l,cl,ml]`, `piece→[piece]`.
   `Units.allowed_for(base_unit)` returns the allowed units list for a given base_unit.
   `Units::Converter` (`app/services/units/converter.rb`) — Single source of truth for unit conversions.
   Exposes `to_kg(quantity, unit, product:)` and `to_display_unit(quantity_kg, unit, product:)`.
   Rules: kg=identity, g÷1000, l=1kg, cl÷100, ml÷1000, piece×unit_weight_kg. Returns 0.0 if piece weight missing.
1. `ProductPurchases::PricePerKgCalculator.call(purchase)` — Calculates `package_quantity_kg` and `price_per_kg`. Delegates conversion to `Units::Converter`. Guards against division by zero. Does NOT persist.
2. `Products::VariabilityCalculator.call(product)` — Returns coefficient of variation (CV%) of active purchases' `price_per_kg`. Population stddev (÷ N). Returns `nil` if < 2 active purchases or mean ≤ 0. Rounded to 2 decimals. Does NOT persist.
3. `Products::AvgPriceRecalculator.call(product)` — Weighted average of active purchases (`SUM(qty_kg × price_per_kg) / SUM(qty_kg)`). Rounded to 4 decimals. Persists via `update_columns`. Raises `ArgumentError` if result is nil or negative.
4. `Recipes::Recalculator.call(recipe)` — Recalculates the 4 `cached_*` fields. Rounding: cost→2 decimals, weight→3 decimals. Persists via `update_columns`. Does NOT cascade to parents.
5. `Recipes::Duplicator.call(recipe)` — Shallow copy of recipe + components, appends " (copie)" to name. Returns unsaved object.
6. `Recalculations::Dispatcher` — Orchestrates cascade and propagates to parent recipes (max 1 level).
   - `.product_purchase_changed(purchase, product: nil)` — AvgPrice → recipes using product → parent recipes
   - `.recipe_component_changed(recipe)` — Recalculator → parent recipes
   - `.recipe_changed(recipe)` — Recalculator → parent recipes
   - `.supplier_force_destroyed(product_ids)` — AvgPrice + recipes for each impacted product
   - `.full_product_recalculation(product)` — Re-saves all purchases → AvgPrice → recipes

Test each service with a dedicated RSpec before integrating into controllers.

### Controllers

| Controller | Routes | Key Logic |
|-----------|--------|-----------|
| `ApplicationController` | Base | `authenticate_user!`, `ensure_subscription!`, `record_not_found` rescue, `Pagy::Backend` (pagination) |
| `PagesController` | `GET /` (home), `GET /subscription_required`, `GET /referentiel-pieces` (HTML + CSV) | Dashboard with resource counts, Référentiel Pièces view with CSV export |
| `SignupsController` | `GET/POST /signup` | Token-based invitation signup, skips auth + subscription |
| `ProductsController` | CRUD `/products` (incl. show) | Search (ILIKE), Pagy pagination, show page with pricing sidebar (PON/MOY), blocks delete if used in recipes |
| `SuppliersController` | CRUD + `activate/deactivate` | Soft-delete, Pagy pagination (active suppliers), force destroy with cascade recalc |
| `ProductPurchasesController` | CRUD + `toggle_active` | Turbo Streams responses, triggers Dispatcher |
| `RecipesController` | CRUD + `duplicate` + `export_excel` + `export_all_excel`, `GET /recipes/tarifs` | Tab filtering (recipes/subrecipes), Pagy pagination, conditional recalc, demotion alert via `Recipe#demotion_alert_message`, Excel export (.xlsx via caxlsx): single recipe or all recipes, optional `detailed` param for costs, `sold_by_unit` g→kg conversion in params + cleanup when unchecked |
| `RecipeComponentsController` | Nested CRUD under recipes | Unit conversion via `Units::Converter`, Turbo Streams, Dispatcher |
| `TraySizesController` | CRUD `/tray_sizes` | Simple packaging sizes, eager-loads recipes (`includes(:recipes)`) |
| `StandardDeviationsController` | `GET /ecarts-types` | Variability index: CV% per product, sorted DESC, N/A products at bottom, Pagy array pagination |
| `SettingsController` | `GET/PATCH /settings` | User `markup_coefficient` + `price_variability_threshold` update (redirects to tray_sizes) |
| `DailySpecialsController` | CRUD `/daily_specials` | Category-based entries (meat/fish/side), averages, 400g portion cost calculation (meat 200g+200g, fish 150g+350g) with markup pricing |
| `Admin::BaseController` | Base admin | `require_admin!`, skips `ensure_subscription!` |
| `Admin::UsersController` | `GET/PATCH /admin/users` | Manage subscription fields (all users accessible) |
| `Admin::InvitationsController` | CRUD `/admin/invitations` | Create invitations, sends `InvitationMailer.invite_user` async via `deliver_later` |

### Mailers

- **ApplicationMailer** — `from:` ENV `MAILER_FROM_ADDRESS`, `reply_to:` ENV `MAILER_REPLY_TO`.
- **InvitationMailer** — `invite_user(invitation)`: sends signup link with token. HTML + text templates with CostChef branding.
- **Dev:** `letter_opener` gem opens emails in browser. **Prod:** SMTP via ENV variables (`SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_DOMAIN`, `SMTP_USERNAME`, `SMTP_PASSWORD`). **Test:** `:test` delivery method.

### Deletion Rules

- **Product:** Block deletion if used in a RecipeComponent (`used_in_recipes?` check).
- **Supplier:** Block deletion if ProductPurchases exist (unless force=true). `force_destroy!` uses `delete_all` (direct SQL, no callbacks). Returns impacted `product_ids` for Dispatcher.
- **TraySize:** `before_destroy` nullifies `tray_size_id` and sets `has_tray=false` in related recipes (no recipe destruction).
- **Recipe:** Block deletion if used as subrecipe (`used_as_subrecipe?` check).

### Frontend Architecture

- **CSS:** Sass compiled via `cssbundling-rails` → `app/assets/builds/application.css`
  - Entry point: `app/assets/stylesheets/application.bootstrap.scss` → imports Bootstrap 5, Bootstrap Icons, `_design_system.scss`
  - Design system: IBM Plex Sans/Mono fonts, slate color palette (`--sl-50` to `--sl-950`), accent cyan (`--accent: #22d3ee`), 13px base font
  - Responsive breakpoints in `_design_system.scss`:
    - `< 1024px` — Narrower recipe sidebar (280px), compact forms, navbar wraps, collapsible grids
    - `< 768px` — Single-column layouts (recipe, products grid, ds-grid), sidebar stacks below with border-top, `data-table` gets `min-width: 600px` (scrolls in `.table-responsive`), `recipe-main` has `min-width: 0` (grid shrink fix), `section-card` has `overflow: hidden`
    - `< 576px` — Dashboard 2-col grid, single-column forms, compact recipe padding
- **JS:** Stimulus controllers in `app/javascript/controllers/`:
  - `unit_select_controller.js` — Toggle weight field for piece-based products
  - `unified_search_controller.js` — Combined product/sub-recipe search modal
  - `toggle_edit_controller.js` — Toggle edit row visibility
  - `char_counter_controller.js` — Character count for textareas
  - `supplier_search_controller.js` — Autocomplete supplier search
  - `tray_toggle_controller.js` — Toggle tray size wrapper visibility
  - `unit_toggle_controller.js` — Toggle unit weight field for sold-by-unit recipes
- **Views:** ERB templates with Bootstrap 5 components
  - Product card displays two prices: PON (weighted avg, green) and MOY (simple avg, blue/cyan)
  - Product show page: two-column layout with purchases list + pricing sidebar (PON, MOY, variability badge)
  - Products index uses Bootstrap accordion (`data-bs-parent`) — only one product's purchases section open at a time (desktop only, hidden on mobile)
  - Recipes index: rows are clickable links (native `link_to`, no Stimulus controller)
  - Purchase form `package_unit` select is filtered by `Units.allowed_for(product.base_unit)`
- **Turbo Streams:** Used by ProductPurchasesController and RecipeComponentsController for dynamic updates

### Auth & Access

- **Devise** for authentication, signup by invitation only (registration route skipped). Min password 8 chars. Modules: `:lockable` (5 attempts, 1h unlock), `:timeoutable` (30min inactivity). Mailer sender from ENV `MAILER_FROM_ADDRESS`.
- **Rack::Attack** rate limiting (`config/initializers/rack_attack.rb`): login 5/min (by IP + email), signup 3/min, password reset 5/min, admin invitations 5/min. Custom 429 response in French. Disabled in test env (enabled explicitly in `rack_attack_spec`).
- **CSP** (`config/initializers/content_security_policy.rb`): strict directives, Google Fonts in `font-src`/`style-src`, no CDN Bootstrap Icons (bundled locally).
- **Production hardening**: `config.hosts` DNS rebinding protection, ActionCable set to `async` (not redis, unused), no `solid_queue` (removed orphan config).
- **Subscription gate** (`ensure_subscription!`) in `ApplicationController` — redirects to `/subscription_required` if `subscription_active == false`.
- **Admin namespace** (`/admin`) inherits from `Admin::BaseController` with `require_admin!` check + `skip_before_action :ensure_subscription!`.
- **SignupsController** — skips both `authenticate_user!` and `ensure_subscription!`. Validates invitation token (`valid_for_signup?`: not used + not expired). On success: creates user, calls `invitation.mark_as_used!`, auto sign-in.
- **PagesController** — `home` (root, requires auth + subscription, shows counters), `subscription_required` (requires auth only), `referentiel_pieces` (requires auth + subscription, piece-based products list + CSV export).

### Pagination (Pagy)

- **Config:** `config/initializers/pagy.rb` — `Pagy::DEFAULT[:items] = 50`, Bootstrap 5 nav extra, Array extra (for `pagy_array`).
- **Paginated index actions:** `ProductsController#index`, `RecipesController#index`, `SuppliersController#index` (active suppliers only), `StandardDeviationsController#index` (pagy_array).
- **Views:** `pagy_bootstrap_nav(@pagy)` in `products/index`, `recipes/index`, `suppliers/index`.

### Test Suite (570 specs)

**Setup:**
- `spec/factories.rb` — Single file with all factories (user, supplier, product, product_purchase, recipe, recipe_component, daily_special, invitation, tray_size). Key traits: product `:piece`/`:liquid`, product_purchase `:in_grams`/`:in_pieces`/`:in_liters`/`:in_cl`/`:inactive`/`:uncalculated`, recipe `:subrecipe`/`:sold_by_unit`, recipe_component `:with_subrecipe`/`:in_grams`/`:in_liters`/`:in_pieces`, invitation `:expired`/`:used`/`:pending`.
- `spec/support/devise.rb` — Includes `Devise::Test::IntegrationHelpers` for request specs.
- `spec/support/database_cleaner.rb` + `spec/support/factory_bot.rb` — Standard config.
- `shoulda-matchers` configured for RSpec + Rails.

**Conventions:**
- Request specs use `sign_in user` (Devise helper), `before(:each)` only (no `before(:all)`).
- Use `let!` (eager) for invitation in POST specs where `expect { }.to change(User, :count)` — avoids counting the admin user created by the invitation factory.
- Product factory has a uniqueness constraint on `name` per user — use distinct names when creating multiple products (not `create_list`).

**Spec files:**
- `spec/services/` — 8 service specs (Units module, Units::Converter, PricePerKgCalculator, VariabilityCalculator, AvgPriceRecalculator, Recalculator, Duplicator, Dispatcher). 64 examples.
- `spec/models/correctifs_spec.rb` — 12 examples. RecipeComponent quantity_unit, ProductPurchase calculated fields + package_unit, Supplier#force_destroy!, DailySpecial averages.
- `spec/models/product_spec.rb` — 30 examples. Validations (name, base_unit, avg_price_per_kg), unit_weight_kg, methods, defaults, simple_avg_price_per_kg.
- `spec/models/product_purchase_spec.rb` — 36 examples. Validations, supplier_belongs_to_same_user, package_unit_matches_base_unit, scopes, toggle_active!, defaults.
- `spec/models/recipe_spec.rb` — 57 examples. Validations (name, description, cooking_loss, tray_size, sold_by_unit), defaults, scopes, business methods, calculations, demotion_alert_message, unit_cost, unit_selling_price.
- `spec/models/recipe_component_spec.rb` — 34 examples. Validations (quantity, unit, type, uniqueness), business validations (sellable, max_depth, self/circular ref, same_user), instance methods.
- `spec/models/daily_special_spec.rb` — 15 examples. Validations, scopes, averages.
- `spec/models/tray_size_spec.rb` — 14 examples. Validations, associations, nullify on delete, eager-loaded recipes_count.
- `spec/requests/pages_spec.rb` — 14 examples. GET / (auth, subscription gate, counters) + GET /subscription_required + GET /referentiel-pieces (auth, piece products, isolation, CSV export).
- `spec/requests/signups_spec.rb` — 17 examples. GET /signup + POST /signup.
- `spec/requests/products_spec.rb` — 32 examples. Index (auth, search, pagination), show (pricing, isolation, 404), POST, PATCH, DELETE.
- `spec/requests/suppliers_spec.rb` — 31 examples. Index (pagination), POST, PATCH, activate/deactivate, DELETE, force destroy, isolation.
- `spec/requests/product_purchases_spec.rb` — 21 examples. POST, PATCH, DELETE, toggle_active with turbo_stream.
- `spec/requests/recipes_spec.rb` — 58 examples. Index (auth, search, tabs, pagination), show, new, create (incl. sold_by_unit g→kg), edit, update (incl. sold_by_unit), destroy, duplicate, export_excel, export_all_excel, tarifs.
- `spec/requests/recipe_components_spec.rb` — 28 examples. POST (kg, g, sub-recipe), PATCH, DELETE with turbo_stream + isolation.
- `spec/requests/tray_sizes_spec.rb` — 19 examples. CRUD + association handling + eager-loaded index.
- `spec/requests/daily_specials_spec.rb` — 14 examples. CRUD by category, 400g portion cost calculation.
- `spec/requests/standard_deviations_spec.rb` — 6 examples. Auth, subscription, success, user isolation, CV DESC sort, N/A at bottom.
- `spec/requests/settings_spec.rb` — 10 examples. Edit + update markup_coefficient + price_variability_threshold.
- `spec/requests/admin/invitations_spec.rb` — 13 examples. Index/new/create with auth + email validation + have_enqueued_mail.
- `spec/requests/admin/users_spec.rb` — 9 examples. Index + update (subscription_active, notes, non-admin blocked).
- `spec/requests/rack_attack_spec.rb` — 5 examples. Login, signup, password reset throttling.
- `spec/deployment/pre_deploy_spec.rb` — 12 examples. Secrets/gitignore, .env.example completeness, schema.rb currency, production config safety, CSP headers, Docker best practices.
- `spec/mailers/invitation_mailer_spec.rb` — 5 examples. Subject, recipient, sender, signup link with token, expiration mention.

### Key Dependencies

**Backend:** Rails 7.1.6, Devise, Pagy, Puma, PostgreSQL (pg), Rack::Attack, Sprockets-Rails, Importmap-Rails, caxlsx (Excel export)
**Frontend:** Turbo-Rails, Stimulus-Rails, cssbundling-rails, Bootstrap 5.3, Bootstrap Icons, Sass, PostCSS + Autoprefixer
**Dev:** Pry-Rails, Better Errors, Bullet (N+1 detection), RuboCop ~1.68 + rubocop-rails ~2.27, letter_opener (email preview)
**Test:** RSpec-Rails, FactoryBot, Faker, Shoulda-Matchers, Capybara, Selenium, DatabaseCleaner
