# frozen_string_literal: true

module Products
  # Weighted average price per kg of a product's ACTIVE purchases, per
  # supplier, compared with the product's overall weighted average.
  # Read-only. Sorted from cheapest to most expensive.
  #
  #   Products::SupplierBreakdown.call(product)
  #   # => [{ supplier: <Supplier>, avg_price_per_kg: 12.3, purchases_count: 1, delta_pct: -18.3 }, ...]
  class SupplierBreakdown
    def self.call(product)
      new(product).call
    end

    def initialize(product)
      raise ArgumentError, 'product is required' if product.nil?

      @product = product
    end

    def call
      @product.product_purchases.active.includes(:supplier)
              .group_by(&:supplier)
              .map { |supplier, purchases| row(supplier, purchases) }
              .sort_by { |line| line[:avg_price_per_kg] }
    end

    private

    def row(supplier, purchases)
      avg = weighted_average(purchases)
      { supplier: supplier, avg_price_per_kg: avg, purchases_count: purchases.size, delta_pct: delta(avg) }
    end

    def weighted_average(purchases)
      quantity = purchases.sum { |p| p.package_quantity_kg.to_d }
      return BigDecimal('0') unless quantity.positive?

      (purchases.sum { |p| p.package_quantity_kg.to_d * p.price_per_kg.to_d } / quantity).round(2)
    end

    def delta(avg)
      overall = @product.avg_price_per_kg.to_d
      return nil unless overall.positive?

      ((avg - overall) / overall * 100).round(1)
    end
  end
end
