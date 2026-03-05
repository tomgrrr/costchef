# frozen_string_literal: true

require 'csv'

class PagesController < ApplicationController
  skip_before_action :ensure_subscription!, only: :subscription_required

  def home
    @products_count       = current_user.products.count
    @recipes_count        = current_user.recipes.count
    @suppliers_count      = current_user.suppliers.count
    @tray_sizes_count     = current_user.tray_sizes.count
    @piece_products_count = current_user.products.where(base_unit: 'piece').count
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

  def generate_pieces_csv(products)
    CSV.generate(col_sep: ';') do |csv|
      csv << ['Nom', 'Poids unitaire (g)', 'Poids unitaire (kg)', 'Prix moyen (€/kg)']
      products.each do |p|
        csv << [p.name, (p.unit_weight_kg * 1000).round(0), p.unit_weight_kg.round(3), p.avg_price_per_kg.round(2)]
      end
    end
  end
end
