# frozen_string_literal: true

require 'csv'

class PagesController < ApplicationController
  skip_before_action :ensure_subscription!, only: :subscription_required

  def home
    load_counts
    @high_variability_count = high_variability_count
    @zero_price_count = current_user.products.where(avg_price_per_kg: 0).count
    @recent_changes = Products::RecentPriceChanges.call(current_user, limit: 6)
    @recent_recipes = current_user.recipes.order(updated_at: :desc).limit(4)
  end

  def referentiel_pieces
    @piece_products = current_user.products.where(base_unit: 'piece').order(:name)

    respond_to do |format|
      format.html
      format.csv do
        send_data generate_pieces_csv(@piece_products),
                  filename: "referentiel-pieces-#{Date.today}.csv",
                  type: 'text/csv; charset=utf-8'
      end
    end
  end

  def subscription_required; end

  private

  # Same rule as Product#high_variability?, on preloaded purchases (one query).
  def high_variability_count
    threshold = current_user.price_variability_threshold
    current_user.products.includes(:product_purchases).count do |product|
      prices = product.product_purchases.select(&:active?).map(&:price_per_kg)
      (variation = Products::VariabilityCalculator.for_prices(prices)) && variation > threshold
    end
  end

  def load_counts
    @products_count    = current_user.products.count
    @recipes_count     = current_user.recipes.where(sellable_as_component: false).count
    @subrecipes_count  = current_user.recipes.where(sellable_as_component: true).count
    @suppliers_count   = current_user.suppliers.active.count
    @tray_sizes_count  = current_user.tray_sizes.count
  end

  def generate_pieces_csv(products)
    CSV.generate(col_sep: ';') do |csv|
      csv << ['Nom', 'Poids unitaire (g)', 'Poids unitaire (kg)', 'Prix moyen (€/kg)']
      products.each do |p|
        csv << [p.name, (p.unit_weight_kg * 1000).round(0), p.unit_weight_kg.round(3), p.avg_price_per_kg.round(2)]
      end
    end
  end
end
