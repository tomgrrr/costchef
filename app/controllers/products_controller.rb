# frozen_string_literal: true

class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]

  # GET /products
  def index
    @products = current_user.products.order(:name)
  end

  # GET /products/:id
  def show
    @suppliers = current_user.suppliers.active.order(:name)
    @product_purchase = @product.product_purchases.build
  end

  # GET /products/new
  def new
    @product = current_user.products.build
  end

  # POST /products
  def create
    @product = current_user.products.build(product_params)

    if @product.save
      redirect_to products_path, notice: 'Produit créé avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /products/:id/edit
  def edit
    # @product déjà chargé via before_action
  end

  # PATCH/PUT /products/:id
  def update
    if @product.update(product_params)
      redirect_to product_path(@product), notice: 'Produit mis à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /products/:id
  def destroy
    @product.destroy!
    redirect_to products_path, notice: 'Produit supprimé avec succès.'
  rescue ActiveRecord::InvalidForeignKey, ActiveRecord::RecordNotDestroyed
    redirect_to products_path, alert: 'Impossible de supprimer ce produit car il est utilisé dans des recettes.'
  end

  private

  # Charge le produit uniquement via current_user (isolation multi-tenant)
  def set_product
    @product = current_user.products.find(params[:id])
  end

  # Strong parameters - JAMAIS permettre :user_id
  def product_params
    params.require(:product).permit(:name, :base_unit, :unit_weight_kg)
  end
end
