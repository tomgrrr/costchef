# frozen_string_literal: true

class ProductPurchasesController < ApplicationController
  before_action :set_product
  before_action :set_purchase, only: %i[update destroy toggle_active]

  # POST /products/:product_id/product_purchases
  def create
    @purchase = @product.product_purchases.build(purchase_params)
    calculate_and_save_purchase
  end

  # PATCH/PUT /products/:product_id/product_purchases/:id
  def update
    @purchase.assign_attributes(purchase_params)
    calculate_and_save_purchase
  end

  # DELETE /products/:product_id/product_purchases/:id
  def destroy
    product = @purchase.product
    @purchase.destroy!
    Recalculations::Dispatcher.product_purchase_changed(@purchase, product: product)
    redirect_to product_path(@product), notice: 'Achat supprimé. Prix recalculés.'
  end

  # PATCH /products/:product_id/product_purchases/:id/toggle_active
  def toggle_active
    @purchase.toggle_active!
    Recalculations::Dispatcher.product_purchase_changed(@purchase)
    status = @purchase.active? ? 'activé' : 'désactivé'
    redirect_to product_path(@product), notice: "Achat #{status}. Prix recalculés."
  end

  private

  def set_product
    @product = current_user.products.find(params[:product_id])
  end

  def set_purchase
    @purchase = @product.product_purchases.find(params[:id])
  end

  def purchase_params
    params.require(:product_purchase).permit(:supplier_id, :package_quantity, :package_unit, :package_price)
  end

  def calculate_and_save_purchase
    ProductPurchases::PricePerKgCalculator.call(@purchase)

    if @purchase.save
      Recalculations::Dispatcher.product_purchase_changed(@purchase)
      redirect_to product_path(@product), notice: 'Achat enregistré. Prix recalculés.'
    else
      redirect_to product_path(@product), alert: @purchase.errors.full_messages.join(', ')
    end
  end
end
