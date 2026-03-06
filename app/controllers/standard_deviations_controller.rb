# frozen_string_literal: true

class StandardDeviationsController < ApplicationController
  def index
    products = current_user.products.includes(:product_purchases)

    with_cv = []
    without_cv = []

    products.each do |product|
      cv = Products::VariabilityCalculator.call(product)
      if cv
        with_cv << { product: product, cv: cv, active_count: product.product_purchases.active.size }
      else
        without_cv << { product: product, cv: nil, active_count: product.product_purchases.active.size }
      end
    end

    with_cv.sort_by! { |entry| -entry[:cv] }
    combined = with_cv + without_cv

    @pagy, @product_entries = pagy_array(combined)
    @threshold = current_user.price_variability_threshold
  end
end
