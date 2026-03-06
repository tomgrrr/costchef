# frozen_string_literal: true

module Products
  # Calcule le coefficient de variation (CV%) des prix/kg des achats actifs d'un produit.
  class VariabilityCalculator
    def self.call(product)
      new(product).call
    end

    def initialize(product)
      @product = product
    end

    # Retourne le CV en % (Float), ou nil si < 2 achats actifs
    def call
      prices = @product.product_purchases.active.pluck(:price_per_kg).map(&:to_f)
      return nil if prices.size < 2

      mean = calculate_mean(prices)
      return nil if mean <= 0

      std_dev = calculate_population_stddev(prices, mean)
      ((std_dev / mean) * 100).round(2)
    end

    private

    def calculate_mean(prices)
      prices.sum / prices.size
    end

    # Écart type population (diviseur N, pas N-1)
    def calculate_population_stddev(prices, mean)
      variance = prices.sum { |p| (p - mean)**2 } / prices.size
      Math.sqrt(variance)
    end
  end
end
