# frozen_string_literal: true

class ProductPurchasesController < ApplicationController
  before_action :set_product
  before_action :set_purchase, only: %i[update destroy toggle_active]

  def create
    @purchase = @product.product_purchases.build(purchase_params)
    # No supplier picked: let the "must exist" validation re-render the form
    # instead of a RecordNotFound redirect that wipes the product page.
    @purchase.supplier = current_user.suppliers.find(purchase_params[:supplier_id]) if purchase_params[:supplier_id].present?

    if @purchase.save
      Recalculations::Dispatcher.product_purchase_changed(@purchase)
      @product.reload
      @new_purchase = ProductPurchase.new
      respond_to do |format|
        format.turbo_stream { render_success_streams }
        format.html { redirect_to products_path, notice: "Achat ajouté." }
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

  # The whole product body lives in turbo-frame "purchases_<id>" on the
  # product page; every change re-renders it.
  def render_success_streams
    render_purchases_section(@product, @new_purchase || ProductPurchase.new)
  end

  def render_purchases_stream
    render_purchases_section(@product, @new_purchase)
  end

  def render_streams_for(product)
    render_purchases_section(product, ProductPurchase.new)
  end

  def render_purchases_section(product, new_purchase)
    render turbo_stream: turbo_stream.update(
      "purchases_#{product.id}",
      partial: "product_purchases/purchases_section",
      locals: { product: product, new_purchase: new_purchase, suppliers: active_suppliers,
                purchases: product.product_purchases.includes(:supplier).order(:created_at) }
    )
  end

  def active_suppliers
    current_user.suppliers.active.order(:name)
  end
end
