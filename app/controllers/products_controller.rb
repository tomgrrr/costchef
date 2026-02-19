# frozen_string_literal: true

class ProductsController < ApplicationController
  before_action :set_product, only: %i[edit update destroy]

  def index
    @products = current_user.products
                            .includes(product_purchases: :supplier)
                            .order(:name)
    @products = @products.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
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
    if @product.update(product_params)
      redirect_to products_path, notice: "Produit mis à jour."
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
    params.require(:product).permit(:name, :base_unit, :unit_weight_kg)
  end
end
