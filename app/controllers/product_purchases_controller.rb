# frozen_string_literal: true

class ProductPurchasesController < ApplicationController
  before_action :set_product
  before_action :set_purchase, only: %i[update destroy toggle_active]

  def create
    @purchase = @product.product_purchases.build(purchase_params)
    @purchase.supplier = current_user.suppliers.find(purchase_params[:supplier_id])
    ProductPurchases::PricePerKgCalculator.call(@purchase)

    if @purchase.save
      Recalculations::Dispatcher.product_purchase_changed(@purchase)
      @product.reload
      @new_purchase = ProductPurchase.new
      respond_to do |format|
        format.turbo_stream { render_success_streams }
        format.html { redirect_to products_path, notice: "Conditionnement ajouté." }
      end
    else
      @new_purchase = @purchase
      respond_to do |format|
        format.turbo_stream { render_purchases_stream }
        format.html { redirect_to products_path }
      end
    end
  end

  def update
    @purchase.assign_attributes(purchase_params)
    ProductPurchases::PricePerKgCalculator.call(@purchase)

    if @purchase.save
      Recalculations::Dispatcher.product_purchase_changed(@purchase)
      @product.reload
      @new_purchase = ProductPurchase.new
      respond_to do |format|
        format.turbo_stream { render_success_streams }
        format.html { redirect_to products_path }
      end
    else
      @new_purchase = @purchase
      respond_to do |format|
        format.turbo_stream { render_purchases_stream }
        format.html { redirect_to products_path }
      end
    end
  end

  def destroy
    product = @product
    @purchase.destroy!
    Recalculations::Dispatcher.product_purchase_changed(nil, product: product)
    product.reload

    respond_to do |format|
      format.turbo_stream { render_streams_for(product) }
      format.html { redirect_to products_path }
    end
  end

  def toggle_active
    @purchase.toggle_active!
    Recalculations::Dispatcher.product_purchase_changed(nil, product: @product)
    @product.reload
    @new_purchase = ProductPurchase.new

    respond_to do |format|
      format.turbo_stream { render_success_streams }
      format.html { redirect_to products_path }
    end
  end

  private

  def set_product
    @product = current_user.products.find(params[:product_id])
  end

  def set_purchase
    @purchase = @product.product_purchases.find(params[:id])
  end

  def purchase_params
    params.require(:product_purchase)
          .permit(:supplier_id, :package_quantity, :package_unit, :package_price)
  end

  def render_success_streams
    render turbo_stream: [
      turbo_stream.replace("product_#{@product.id}",
                           partial: "products/product_card",
                           locals: { product: @product }),
      turbo_stream.update("purchases_#{@product.id}",
                          partial: "product_purchases/purchases_section",
                          locals: { product: @product,
                                    purchases: @product.product_purchases.order(:created_at),
                                    new_purchase: @new_purchase || ProductPurchase.new,
                                    suppliers: active_suppliers })
    ]
  end

  def render_purchases_stream
    render turbo_stream: turbo_stream.update("purchases_#{@product.id}",
                                             partial: "product_purchases/purchases_section",
                                             locals: { product: @product,
                                                       purchases: @product.product_purchases.order(:created_at),
                                                       new_purchase: @new_purchase,
                                                       suppliers: active_suppliers })
  end

  def render_streams_for(product)
    render turbo_stream: [
      turbo_stream.replace("product_#{product.id}",
                           partial: "products/product_card",
                           locals: { product: product }),
      turbo_stream.update("purchases_#{product.id}",
                          partial: "product_purchases/purchases_section",
                          locals: { product: product,
                                    purchases: product.product_purchases.order(:created_at),
                                    new_purchase: ProductPurchase.new,
                                    suppliers: active_suppliers })
    ]
  end

  def active_suppliers
    current_user.suppliers.active.order(:name)
  end
end
