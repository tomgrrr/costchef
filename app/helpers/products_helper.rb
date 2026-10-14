# frozen_string_literal: true

# Display helpers for products. They read preloaded purchases (no queries)
# so list pages stay at one query per page.
module ProductsHelper
  # "Au kilo", "Au litre", "À la pièce · 50 g", "Déshydraté · réhydratation ×8".
  def product_unit_label(product)
    case product.base_unit
    when 'l' then 'Au litre'
    when 'piece' then "À la pièce · #{weight_label(product.unit_weight_kg)}"
    else product.dehydrated? ? dehydrated_label(product) : 'Au kilo'
    end
  end

  def dehydrated_label(product)
    "Déshydraté · réhydratation ×#{fr_number(product.rehydration_coefficient, strip: true)}"
  end

  # Piece weight for a grams input: 0.0525 kg -> "52.5" (DB keeps 0.1 g precision).
  def grams_value(weight_kg)
    (weight_kg.to_d * 1000).round(1).to_s('F').delete_suffix('.0')
  end

  # Prices are stored per kg; litres count as kilos.
  def product_price_unit(product)
    product.base_unit == 'l' ? 'l' : 'kg'
  end

  def loaded_active_purchases(product)
    product.product_purchases.select(&:active?)
  end

  # Simple (unweighted) average of the preloaded active purchases, nil if none.
  def loaded_simple_average(product)
    active = loaded_active_purchases(product)
    active.sum { |purchase| purchase.price_per_kg.to_d } / active.size if active.any?
  end

  # Price of one piece for piece products, nil without a price or weight.
  def piece_price(product)
    return nil unless product.avg_price_per_kg.to_d.positive? && product.unit_weight_kg

    product.avg_price_per_kg.to_d * product.unit_weight_kg.to_d
  end

  # CV% of active purchase prices, nil when fewer than two.
  def product_variability(product)
    Products::VariabilityCalculator.for_prices(loaded_active_purchases(product).map(&:price_per_kg))
  end

  def variability_alert?(variation)
    variation.present? && variation > current_user.price_variability_threshold
  end

  def latest_purchase(product)
    product.product_purchases.max_by(&:created_at)
  end

  CHART = { left: 52, right: 620, top: 28, bottom: 168 }.freeze

  # Geometry for the price-history chart (viewBox 0 0 640 200): one point per
  # purchase in date order, three horizontal guides, the weighted average line.
  def price_chart(purchases, average)
    average = average.to_f
    low, high = chart_range(chart_values(purchases, average))
    y_for = ->(price) { chart_y(price, low, high) }
    { points: chart_points(purchases, y_for), guides: chart_guides(low, high, y_for),
      average_y: (y_for.call(average) if average.positive?) }
  end

  private

  # The average joins the scale only when there is one (all purchases
  # inactive means an average of 0, which would squash the line).
  def chart_values(purchases, average)
    prices = purchases.map { |p| p.price_per_kg.to_f }
    average.positive? ? prices + [average] : prices
  end

  def chart_range(values)
    low = values.min
    high = values.max
    pad = [(high - low) * 0.12, high * 0.05, 0.1].max
    [[low - pad, 0].max, high + pad]
  end

  def chart_y(price, low, high)
    (CHART[:bottom] - ((price - low) / (high - low) * (CHART[:bottom] - CHART[:top]))).round(1)
  end

  def chart_points(purchases, y_for)
    step = chart_step(purchases.size)
    last_index = purchases.size - 1
    purchases.each_with_index.map do |purchase, index|
      { x: (CHART[:left] + (step * index)).round(1), y: y_for.call(purchase.price_per_kg.to_f),
        purchase: purchase, last: index == last_index }
    end
  end

  def chart_step(count)
    count > 1 ? (CHART[:right] - CHART[:left]).to_f / (count - 1) : 0
  end

  def chart_guides(low, high, y_for)
    [0.15, 0.5, 0.85].map do |ratio|
      value = low + ((high - low) * ratio)
      { y: y_for.call(value), label: eur(value, precision: value >= 100 ? 0 : 2) }
    end
  end
end
