# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_02_16_141550) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "daily_specials", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "category", null: false
    t.date "entry_date", null: false
    t.string "item_name", null: false
    t.decimal "cost_per_kg", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "category"], name: "index_daily_specials_on_user_id_and_category"
    t.index ["user_id", "entry_date"], name: "index_daily_specials_on_user_id_and_entry_date"
    t.index ["user_id"], name: "index_daily_specials_on_user_id"
    t.check_constraint "category::text = ANY (ARRAY['meat'::character varying, 'fish'::character varying, 'side'::character varying]::text[])", name: "valid_category"
    t.check_constraint "cost_per_kg > 0::numeric", name: "cost_per_kg_positive"
  end

  create_table "invitations", force: :cascade do |t|
    t.string "email", null: false
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.datetime "used_at"
    t.bigint "created_by_admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_admin_id"], name: "index_invitations_on_created_by_admin_id"
    t.index ["email"], name: "index_invitations_on_email", unique: true
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "product_purchases", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "supplier_id", null: false
    t.decimal "package_quantity", precision: 10, scale: 3, null: false
    t.string "package_unit", default: "kg", null: false
    t.decimal "package_quantity_kg", precision: 10, scale: 3, null: false
    t.decimal "package_price", precision: 10, scale: 2, null: false
    t.decimal "price_per_kg", precision: 10, scale: 4, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "active"], name: "index_product_purchases_on_product_and_active"
    t.index ["product_id", "supplier_id"], name: "index_product_purchases_on_product_id_and_supplier_id"
    t.index ["product_id"], name: "index_product_purchases_on_product_id"
    t.index ["supplier_id"], name: "index_product_purchases_on_supplier_id"
    t.check_constraint "package_price >= 0::numeric", name: "package_price_positive"
    t.check_constraint "package_quantity > 0::numeric", name: "package_quantity_positive"
    t.check_constraint "package_quantity_kg > 0::numeric", name: "package_quantity_kg_positive"
    t.check_constraint "price_per_kg >= 0::numeric", name: "price_per_kg_positive"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "base_unit", default: "kg", null: false
    t.decimal "unit_weight_kg", precision: 10, scale: 4
    t.decimal "avg_price_per_kg", precision: 10, scale: 4, default: "0.0", null: false
    t.index ["name"], name: "index_products_on_name"
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "recipe_components", force: :cascade do |t|
    t.bigint "parent_recipe_id", null: false
    t.string "component_type", null: false
    t.bigint "component_id", null: false
    t.decimal "quantity_kg", precision: 10, scale: 3, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_type", "component_id"], name: "index_recipe_components_on_component_type_and_component_id"
    t.index ["parent_recipe_id", "component_type", "component_id"], name: "index_recipe_components_uniqueness", unique: true
    t.index ["parent_recipe_id"], name: "index_recipe_components_on_parent_recipe_id"
    t.check_constraint "component_type::text = ANY (ARRAY['Product'::character varying, 'Recipe'::character varying]::text[])", name: "valid_component_type"
    t.check_constraint "quantity_kg > 0::numeric", name: "quantity_kg_positive"
  end

  create_table "recipe_ingredients", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.bigint "product_id", null: false
    t.decimal "quantity", precision: 10, scale: 3, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_recipe_ingredients_on_product_id"
    t.index ["recipe_id", "product_id"], name: "index_recipe_ingredients_on_recipe_id_and_product_id"
    t.index ["recipe_id"], name: "index_recipe_ingredients_on_recipe_id"
    t.check_constraint "quantity > 0::numeric", name: "quantity_positive"
  end

  create_table "recipes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.text "description"
    t.decimal "cached_total_cost", precision: 10, scale: 2
    t.decimal "cached_total_weight", precision: 10, scale: 3
    t.decimal "cached_cost_per_kg", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "sellable_as_component", default: false, null: false
    t.decimal "cooking_loss_percentage", precision: 5, scale: 2, default: "0.0"
    t.boolean "has_tray", default: false, null: false
    t.bigint "tray_size_id"
    t.decimal "cached_raw_weight", precision: 10, scale: 3
    t.index ["cached_cost_per_kg"], name: "index_recipes_on_cached_cost_per_kg"
    t.index ["name"], name: "index_recipes_on_name"
    t.index ["tray_size_id"], name: "index_recipes_on_tray_size_id"
    t.index ["user_id", "name"], name: "index_recipes_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_recipes_on_user_id"
    t.check_constraint "cached_raw_weight IS NULL OR cached_raw_weight >= 0::numeric", name: "cached_raw_weight_positive"
    t.check_constraint "cooking_loss_percentage >= 0::numeric AND cooking_loss_percentage <= 100::numeric", name: "cooking_loss_percentage_range"
  end

  create_table "suppliers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_suppliers_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_suppliers_on_user_id"
  end

  create_table "tray_sizes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.decimal "price", precision: 8, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_tray_sizes_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_tray_sizes_on_user_id"
    t.check_constraint "price >= 0::numeric", name: "tray_price_positive"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name"
    t.string "last_name"
    t.string "company_name"
    t.boolean "subscription_active", default: false, null: false
    t.date "subscription_started_at"
    t.date "subscription_expires_at"
    t.text "subscription_notes"
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "markup_coefficient", precision: 5, scale: 2, default: "1.0", null: false
    t.index ["admin"], name: "index_users_on_admin"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["subscription_active"], name: "index_users_on_subscription_active"
  end

  add_foreign_key "daily_specials", "users", on_delete: :cascade
  add_foreign_key "invitations", "users", column: "created_by_admin_id"
  add_foreign_key "product_purchases", "products", on_delete: :cascade
  add_foreign_key "product_purchases", "suppliers", on_delete: :restrict
  add_foreign_key "products", "users", on_delete: :cascade
  add_foreign_key "recipe_components", "recipes", column: "parent_recipe_id", on_delete: :cascade
  add_foreign_key "recipe_ingredients", "products", on_delete: :restrict
  add_foreign_key "recipe_ingredients", "recipes", on_delete: :cascade
  add_foreign_key "recipes", "tray_sizes", on_delete: :nullify
  add_foreign_key "recipes", "users", on_delete: :cascade
  add_foreign_key "suppliers", "users", on_delete: :cascade
  add_foreign_key "tray_sizes", "users", on_delete: :cascade
end
