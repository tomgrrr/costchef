# frozen_string_literal: true

module Products
  # Products whose latest active purchase changed the price per kg, compared
  # with the purchase just before it (active or not). One line per product,
  # newest first. Read-only, for the dashboard.
  #
  #   Products::RecentPriceChanges.call(user, limit: 6)
  #   # => [{ product:, purchase:, previous:, delta_pct: 16.7, recipes_count: 3 }, ...]
  class RecentPriceChanges
    def self.call(user, limit: 6)
      new(user, limit).call
    end

    def initialize(user, limit)
      raise ArgumentError, 'user is required' if user.nil?

      @user = user
      @limit = limit
    end

    # Every product is considered, in a fixed number of queries whatever the catalogue size.
    def call
      latest = latest_purchases
      previous = previous_purchases(latest)
      with_recipe_counts(latest.filter_map { |purchase| change_for(purchase, previous[purchase.id]) }.first(@limit))
    end

    private

    def with_recipe_counts(changes)
      counts = recipe_counts(changes.map { |c| c[:product].id })
      changes.each { |change| change[:recipes_count] = counts[change[:product].id].to_i }
    end

    # The latest active purchase of each of the user's products, newest first.
    def latest_purchases
      ids = ProductPurchase.active.joins(:product).where(products: { user_id: @user.id })
                           .select('DISTINCT ON (product_purchases.product_id) product_purchases.id')
                           .order('product_purchases.product_id, product_purchases.created_at DESC, ' \
                                  'product_purchases.id DESC')
      ProductPurchase.where(id: ids).includes(:product, :supplier).order(created_at: :desc, id: :desc).to_a
    end

    # { latest purchase id => the purchase just before it, active or not }
    def previous_purchases(latest)
      pairs = previous_ids(latest)
      found = ProductPurchase.where(id: pairs.values.compact).index_by(&:id)
      pairs.transform_values { |id| found[id] }
    end

    def previous_ids(latest)
      ranked = ProductPurchase.where(product_id: latest.map(&:product_id))
                              .select('product_purchases.id', 'LAG(product_purchases.id) OVER ' \
                                      '(PARTITION BY product_id ORDER BY created_at, id) AS previous_id')
      ProductPurchase.from(ranked, :product_purchases).where(id: latest.map(&:id)).pluck(:id, :previous_id).to_h
    end

    def change_for(purchase, previous)
      return nil unless previous&.price_per_kg.to_d.positive?

      delta = (purchase.price_per_kg.to_d - previous.price_per_kg.to_d) / previous.price_per_kg.to_d * 100
      return nil if delta.abs < 0.5

      { product: purchase.product, purchase: purchase, previous: previous, delta_pct: delta.round(1) }
    end

    def recipe_counts(product_ids)
      RecipeComponent.where(component_type: 'Product', component_id: product_ids)
                     .group(:component_id).distinct.count(:parent_recipe_id)
    end
  end
end
