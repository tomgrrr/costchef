# frozen_string_literal: true

module Products
  # Products whose latest active purchase changed the price per kg, compared
  # with the purchase just before it (active or not). One line per product,
  # newest first. Read-only, for the dashboard.
  #
  #   Products::RecentPriceChanges.call(user, limit: 6)
  #   # => [{ product:, purchase:, previous:, delta_pct: 16.7, recipes_count: 3 }, ...]
  class RecentPriceChanges
    SCAN_FACTOR = 4 # look a bit further back so unchanged prices don't empty the list

    def self.call(user, limit: 6)
      new(user, limit).call
    end

    def initialize(user, limit)
      raise ArgumentError, 'user is required' if user.nil?

      @user = user
      @limit = limit
    end

    def call
      changes = latest_purchases.uniq(&:product_id).lazy.filter_map { |purchase| change_for(purchase) }.first(@limit)
      counts = recipe_counts(changes.map { |c| c[:product].id })
      changes.each { |change| change[:recipes_count] = counts[change[:product].id].to_i }
    end

    private

    def latest_purchases
      ProductPurchase.active.joins(:product).where(products: { user_id: @user.id })
                     .includes(:product, :supplier)
                     .order(created_at: :desc).limit(@limit * SCAN_FACTOR)
    end

    def change_for(purchase)
      previous = previous_purchase(purchase)
      return nil unless previous&.price_per_kg.to_d.positive?

      delta = (purchase.price_per_kg.to_d - previous.price_per_kg.to_d) / previous.price_per_kg.to_d * 100
      return nil if delta.abs < 0.5

      { product: purchase.product, purchase: purchase, previous: previous, delta_pct: delta.round(1) }
    end

    def previous_purchase(purchase)
      purchase.product.product_purchases
              .where('product_purchases.created_at < ?', purchase.created_at)
              .order(created_at: :desc).first
    end

    def recipe_counts(product_ids)
      RecipeComponent.where(component_type: 'Product', component_id: product_ids)
                     .group(:component_id).distinct.count(:parent_recipe_id)
    end
  end
end
