# frozen_string_literal: true

module Suppliers
  # For one supplier, compares the prices of each product bought from it
  # with the product's overall weighted average (all suppliers). Read-only.
  # Moved out of suppliers/show.html.erb, where it was computed inline.
  #
  #   Suppliers::PriceComparison.call(supplier)
  #   # => [{ product:, purchases:, active_purchases:, weighted_avg:, simple_avg:,
  #   #      global_avg:, delta_pct:, active_quantity_kg: }, ...] sorted by product name
  class PriceComparison
    def self.call(supplier)
      new(supplier).call
    end

    def initialize(supplier)
      raise ArgumentError, 'supplier is required' if supplier.nil?

      @supplier = supplier
    end

    def call
      @supplier.product_purchases.includes(:product)
               .order('products.name ASC, product_purchases.created_at ASC')
               .group_by(&:product)
               .map { |product, purchases| row(product, purchases) }
    end

    private

    def row(product, purchases)
      active = purchases.select(&:active?)
      weighted = weighted_average(active)
      global = product.avg_price_per_kg.to_d.positive? ? product.avg_price_per_kg.to_d : nil
      { product: product, purchases: sort(purchases), active_purchases: active,
        weighted_avg: weighted, simple_avg: simple_average(active), global_avg: global,
        delta_pct: delta(weighted, global), active_quantity_kg: active.sum { |p| p.package_quantity_kg.to_d } }
    end

    def sort(purchases)
      purchases.sort_by { |p| [p.active? ? 0 : 1, p.created_at] }
    end

    def weighted_average(purchases)
      quantity = purchases.sum { |p| p.package_quantity_kg.to_d }
      return nil unless quantity.positive?

      purchases.sum { |p| p.package_quantity_kg.to_d * p.price_per_kg.to_d } / quantity
    end

    def simple_average(purchases)
      return nil if purchases.empty?

      purchases.sum { |p| p.price_per_kg.to_d } / purchases.size
    end

    def delta(weighted, global)
      return nil unless weighted && global

      ((weighted - global) / global * 100).round(1)
    end
  end
end
