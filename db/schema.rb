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

ActiveRecord::Schema[7.1].define(version: 20_260_204_160_745) do
  # Extension
  enable_extension 'plpgsql'

  create_table 'products', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.string 'name', null: false
    t.decimal 'price', precision: 8, scale: 2, null: false
    t.string 'unit'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['name'], name: 'index_products_on_name'
    t.index %w[user_id name], name: 'index_products_on_user_id_and_name', unique: true
    t.index ['user_id'], name: 'index_products_on_user_id'
    t.check_constraint 'price > 0::numeric', name: 'price_positive'
  end

  create_table 'recipe_ingredients', force: :cascade do |t|
    t.bigint 'recipe_id', null: false
    t.bigint 'product_id', null: false
    t.decimal 'quantity', precision: 10, scale: 3, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['product_id'], name: 'index_recipe_ingredients_on_product_id'
    t.index %w[recipe_id product_id], name: 'index_recipe_ingredients_on_recipe_id_and_product_id'
    t.index ['recipe_id'], name: 'index_recipe_ingredients_on_recipe_id'
    t.check_constraint 'quantity > 0::numeric', name: 'quantity_positive'
  end

  create_table 'recipes', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.string 'name', null: false
    t.text 'description'
    t.decimal 'cached_total_cost', precision: 10, scale: 2
    t.decimal 'cached_total_weight', precision: 10, scale: 3
    t.decimal 'cached_cost_per_kg', precision: 10, scale: 2
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['cached_cost_per_kg'], name: 'index_recipes_on_cached_cost_per_kg'
    t.index ['name'], name: 'index_recipes_on_name'
    t.index %w[user_id name], name: 'index_recipes_on_user_id_and_name', unique: true
    t.index ['user_id'], name: 'index_recipes_on_user_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'email', default: '', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.string 'first_name'
    t.string 'last_name'
    t.string 'company_name'
    t.boolean 'subscription_active', default: false, null: false
    t.date 'subscription_started_at'
    t.date 'subscription_expires_at'
    t.text 'subscription_notes'
    t.boolean 'admin', default: false, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['admin'], name: 'index_users_on_admin'
    t.index ['email'], name: 'index_users_on_email', unique: true
    t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
    t.index ['subscription_active'], name: 'index_users_on_subscription_active'
  end

  add_foreign_key 'products', 'users', on_delete: :cascade
  add_foreign_key 'recipe_ingredients', 'products', on_delete: :restrict
  add_foreign_key 'recipe_ingredients', 'recipes', on_delete: :cascade
  add_foreign_key 'recipes', 'users', on_delete: :cascade
end
