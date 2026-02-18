# frozen_string_literal: true

# Usage: rails runner scripts/e2e_recalculation_test.rb
#
# Tests the full recalculation cascade end-to-end.
# All changes are wrapped in a ROLLBACK transaction — no data is modified.

module E2ETest
  PASS = "\e[32mPASS\e[0m"
  FAIL = "\e[31mFAIL\e[0m"

  @pass_count = 0
  @fail_count = 0

  def self.check(label, expected:, actual:)
    ok = if expected.is_a?(Float)
           (expected - actual.to_f).abs < 0.01
         else
           expected == actual
         end

    if ok
      @pass_count += 1
      puts "  #{PASS} #{label} (#{actual})"
    else
      @fail_count += 1
      puts "  #{FAIL} #{label} — expected: #{expected}, got: #{actual}"
    end
  end

  def self.check_not_nil(label, value)
    if value.present?
      @pass_count += 1
      puts "  #{PASS} #{label} (#{value})"
    else
      @fail_count += 1
      puts "  #{FAIL} #{label} — expected non-nil, got: #{value.inspect}"
    end
  end

  def self.check_changed(label, before:, after:)
    if before != after
      @pass_count += 1
      puts "  #{PASS} #{label} — changed from #{before} to #{after}"
    else
      @fail_count += 1
      puts "  #{FAIL} #{label} — value did NOT change (still #{before})"
    end
  end

  def self.summary
    total = @pass_count + @fail_count
    puts "\n#{'=' * 60}"
    puts "RESULTS: #{@pass_count}/#{total} passed, #{@fail_count} failed"
    puts '=' * 60
  end

  def self.section(title)
    puts "\n#{'—' * 60}"
    puts "▶ #{title}"
    puts '—' * 60
  end
end

ActiveRecord::Base.transaction do
  # Pick the first user that actually has products and recipes
  user = User.joins(:products, :recipes).distinct.first!
  puts "Using user: #{user.email} (id: #{user.id})"

  # ============================================================
  # SCENARIO 1: Recalcul sur modification d'un achat
  # ============================================================
  E2ETest.section("Scénario 1 : Recalcul sur modification d'un achat")

  # Find an active purchase whose product is used in at least one recipe
  purchase = nil
  product = nil
  recipes_using_product = []

  user.products.includes(:product_purchases).find_each do |p|
    active_purchase = p.product_purchases.active.first
    next unless active_purchase

    rcs = RecipeComponent.where(component_type: "Product", component_id: p.id)
    next if rcs.empty?

    recipe_ids = rcs.pluck(:parent_recipe_id)
    recipes = Recipe.where(id: recipe_ids)
    next if recipes.empty?

    purchase = active_purchase
    product = p
    recipes_using_product = recipes.to_a
    break
  end

  if purchase.nil?
    puts "  SKIP — no active purchase linked to a recipe found"
  else
    puts "  Purchase ##{purchase.id} (product: #{product.name})"
    puts "  Recipes using this product: #{recipes_using_product.map(&:name).join(', ')}"

    old_avg = product.avg_price_per_kg
    old_cached = recipes_using_product.map { |r| [r.id, r.cached_total_cost] }.to_h

    # Modify price
    original_price = purchase.package_price
    new_price = (original_price * 1.5).round(2)
    purchase.update_columns(package_price: new_price)

    # Run cascade
    ProductPurchases::PricePerKgCalculator.call(purchase)
    purchase.save!
    Recalculations::Dispatcher.product_purchase_changed(purchase)

    product.reload
    E2ETest.check_changed("avg_price_per_kg changed", before: old_avg, after: product.avg_price_per_kg)

    recipes_using_product.each do |recipe|
      recipe.reload
      E2ETest.check_changed(
        "Recipe '#{recipe.name}' cached_total_cost changed",
        before: old_cached[recipe.id],
        after: recipe.cached_total_cost
      )
    end
  end

  # ============================================================
  # SCENARIO 2: Toggle achat actif/inactif
  # ============================================================
  E2ETest.section("Scénario 2 : Toggle achat actif/inactif")

  # Find a product with at least 1 active purchase; create a 2nd one if needed
  product_with_multi = user.products
    .joins(:product_purchases)
    .where(product_purchases: { active: true })
    .group("products.id")
    .having("COUNT(product_purchases.id) >= 2")
    .first

  # If no product has 2+ active purchases, create a second purchase on the first product that has one
  if product_with_multi.nil?
    candidate = user.products.joins(:product_purchases).where(product_purchases: { active: true }).first
    if candidate
      existing = candidate.product_purchases.active.first
      supplier = existing.supplier
      extra = candidate.product_purchases.create!(
        supplier: supplier,
        package_quantity: existing.package_quantity * 2,
        package_price: existing.package_price * 1.8,
        package_unit: existing.package_unit,
        active: true,
        package_quantity_kg: 1, # placeholder
        price_per_kg: 1         # placeholder
      )
      ProductPurchases::PricePerKgCalculator.call(extra)
      extra.save!
      Products::AvgPriceRecalculator.call(candidate)
      candidate.reload
      product_with_multi = candidate
      puts "  (created extra purchase ##{extra.id} for testing)"
    end
  end

  if product_with_multi.nil?
    puts "  SKIP — no product with active purchases found"
  else
    puts "  Product: #{product_with_multi.name} (id: #{product_with_multi.id})"
    active_purchases = product_with_multi.product_purchases.active
    puts "  Active purchases: #{active_purchases.count}"

    old_avg = product_with_multi.avg_price_per_kg
    target_purchase = active_purchases.first

    # Deactivate one purchase
    target_purchase.update_columns(active: false)
    Recalculations::Dispatcher.product_purchase_changed(target_purchase)

    product_with_multi.reload
    E2ETest.check_changed(
      "avg_price_per_kg changed after deactivating purchase ##{target_purchase.id}",
      before: old_avg,
      after: product_with_multi.avg_price_per_kg
    )
  end

  # ============================================================
  # SCENARIO 3: Modification perte cuisson
  # ============================================================
  E2ETest.section("Scénario 3 : Modification perte cuisson")

  recipe_with_components = user.recipes
    .joins(:recipe_components)
    .distinct
    .first

  if recipe_with_components.nil?
    puts "  SKIP — no recipe with components found"
  else
    puts "  Recipe: #{recipe_with_components.name} (id: #{recipe_with_components.id})"
    puts "  Components: #{recipe_with_components.recipe_components.count}"

    # Make sure cached values are populated
    Recipes::Recalculator.call(recipe_with_components)
    recipe_with_components.reload

    old_cost_per_kg = recipe_with_components.cached_cost_per_kg
    old_loss = recipe_with_components.cooking_loss_percentage
    new_loss = old_loss < 50 ? old_loss + 20 : old_loss - 20
    puts "  cooking_loss_percentage: #{old_loss} → #{new_loss}"

    recipe_with_components.update_columns(cooking_loss_percentage: new_loss)
    Recalculations::Dispatcher.recipe_changed(recipe_with_components)

    recipe_with_components.reload
    E2ETest.check_changed(
      "cached_cost_per_kg changed",
      before: old_cost_per_kg,
      after: recipe_with_components.cached_cost_per_kg
    )

    # Verify formula: cost_per_kg = total_cost / (raw_weight * (1 - loss/100))
    expected_weight = (recipe_with_components.cached_raw_weight * (1.0 - new_loss / 100.0)).round(3)
    E2ETest.check(
      "cached_total_weight matches formula",
      expected: expected_weight,
      actual: recipe_with_components.cached_total_weight
    )
  end

  # ============================================================
  # SCENARIO 4: Duplication de recette
  # ============================================================
  E2ETest.section("Scénario 4 : Duplication de recette")

  original = user.recipes
    .joins(:recipe_components)
    .distinct
    .where.not(cached_total_cost: nil)
    .first

  if original.nil?
    # Try to populate caches on any recipe with components
    original = user.recipes.joins(:recipe_components).distinct.first
    if original
      Recipes::Recalculator.call(original)
      original.reload
    end
  end

  if original.nil?
    puts "  SKIP — no recipe with components found"
  else
    puts "  Original: #{original.name} (id: #{original.id})"
    puts "  Components: #{original.recipe_components.count}"

    # Duplicate (mimic controller logic)
    copy = original.dup
    copy.name = "#{original.name} (E2E test copy)"
    copy.save!

    original.recipe_components.each do |rc|
      copy.recipe_components.create!(
        component_type: rc.component_type,
        component_id: rc.component_id,
        quantity_kg: rc.quantity_kg
      )
    end

    Recalculations::Dispatcher.recipe_component_changed(copy)
    copy.reload

    E2ETest.check_not_nil("copy cached_total_cost", copy.cached_total_cost)
    E2ETest.check_not_nil("copy cached_total_weight", copy.cached_total_weight)
    E2ETest.check_not_nil("copy cached_cost_per_kg", copy.cached_cost_per_kg)
    E2ETest.check_not_nil("copy cached_raw_weight", copy.cached_raw_weight)

    E2ETest.check(
      "cached_total_cost matches original",
      expected: original.cached_total_cost.to_f,
      actual: copy.cached_total_cost.to_f
    )
    E2ETest.check(
      "cached_cost_per_kg matches original",
      expected: original.cached_cost_per_kg.to_f,
      actual: copy.cached_cost_per_kg.to_f
    )
    E2ETest.check(
      "cached_total_weight matches original",
      expected: original.cached_total_weight.to_f,
      actual: copy.cached_total_weight.to_f
    )
  end

  # ============================================================
  # SUMMARY + ROLLBACK
  # ============================================================
  E2ETest.summary

  puts "\nRolling back all changes..."
  raise ActiveRecord::Rollback
end

puts "Done. No data was modified."
