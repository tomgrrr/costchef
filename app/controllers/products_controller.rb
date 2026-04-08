# frozen_string_literal: true

require 'csv'

class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]

  def index
    scope = current_user.products
                        .includes(product_purchases: :supplier)
                        .order(:name)
                        .then { |s| params[:search].present? ? s.where("name ILIKE ?", "%#{params[:search]}%") : s }
                        .then { |s| params[:zero_price] == "1" ? s.where(avg_price_per_kg: 0) : s }

    respond_to do |format|
      format.html { @pagy, @products = pagy(scope, limit: items_per_page) }
      format.csv { send_products_csv(scope) }
    end
  end

  def show
    @purchases = @product.product_purchases.includes(:supplier).order(:created_at)
    @new_purchase = ProductPurchase.new
    @suppliers = current_user.suppliers.active.order(:name)
    @used_in = @product.recipe_components.includes(:parent_recipe).map(&:parent_recipe).uniq.sort_by(&:name)
  end

  def new
    @product = current_user.products.build
  end

  def create
    @product = current_user.products.build(product_params)

    if @product.save
      redirect_to products_path, notice: "Produit créé."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    convert_unit_weight_from_grams if params[:input_unit] == "g"

    if @product.update(product_params)
      trigger_recalculation_if_weight_changed
      redirect_to update_redirect_path, notice: "Produit mis à jour."
    elsif params[:return_to] == "referentiel_pieces"
      redirect_to referentiel_pieces_path, alert: @product.errors.full_messages.join(", ")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @product.used_in_recipes?
      redirect_to products_path,
                  alert: "Ce produit est utilisé dans #{@product.recipes_count} recette(s) et ne peut pas être supprimé."
    else
      @product.destroy!
      redirect_to products_path, notice: "Produit supprimé."
    end
  end

  private

  def set_product
    @product = current_user.products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :base_unit, :unit_weight_kg, :dehydrated, :rehydration_coefficient)
  end

  def convert_unit_weight_from_grams
    weight_g = params.dig(:product, :unit_weight_kg)
    return unless weight_g.present?

    params[:product][:unit_weight_kg] = weight_g.to_f / 1000
  end

  def update_redirect_path
    params[:return_to] == "referentiel_pieces" ? referentiel_pieces_path : products_path
  end

  def items_per_page
    per_page = params[:per_page].to_i
    [20, 50, 100].include?(per_page) ? per_page : 50
  end

  def send_products_csv(products)
    send_data generate_products_csv(products),
              filename: "produits-#{Date.today}.csv",
              type: 'text/csv; charset=utf-8'
  end

  def generate_products_csv(products)
    CSV.generate(col_sep: ';') do |csv|
      csv << ['Nom', 'Unité', 'Poids unitaire (kg)']
      products.each { |p| csv << [p.name, p.base_unit, p.unit_weight_kg&.round(3)] }
    end
  end

  def trigger_recalculation_if_weight_changed
    return unless @product.saved_change_to_unit_weight_kg? ||
                  @product.saved_change_to_rehydration_coefficient? ||
                  @product.saved_change_to_dehydrated?

    Recalculations::Dispatcher.full_product_recalculation(@product)
  end
end
