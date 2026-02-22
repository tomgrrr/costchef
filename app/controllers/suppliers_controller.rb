# frozen_string_literal: true

class SuppliersController < ApplicationController
  before_action :set_supplier, only: %i[edit update destroy activate deactivate]

  def index
    @active_suppliers = current_user.suppliers.where(active: true).order(:name)
    @inactive_suppliers = current_user.suppliers.where(active: false).order(:name)
  end

  def new
    @supplier = current_user.suppliers.build
  end

  def create
    @supplier = current_user.suppliers.build(supplier_params)

    if @supplier.save
      redirect_to suppliers_path, notice: "Fournisseur créé."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @supplier.update(supplier_params)
      redirect_to suppliers_path, notice: "Fournisseur mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if params[:force] == "true"
      impacted_product_ids = @supplier.force_destroy!
      Recalculations::Dispatcher.supplier_force_destroyed(impacted_product_ids)
      redirect_to suppliers_path, notice: "Fournisseur et ses conditionnements supprimés."
    elsif @supplier.has_purchases?
      redirect_to suppliers_path,
                  alert: "Ce fournisseur possède #{@supplier.product_purchases.count} conditionnement(s). " \
                         "Désactivez-le ou utilisez la suppression forcée."
    else
      @supplier.destroy!
      redirect_to suppliers_path, notice: "Fournisseur supprimé."
    end
  end

  def activate
    @supplier.activate!
    redirect_to suppliers_path, notice: "Fournisseur réactivé."
  end

  def deactivate
    product_ids = @supplier.product_purchases.active.pluck(:product_id).uniq
    @supplier.product_purchases.update_all(active: false)
    @supplier.deactivate!
    recalculate_products(product_ids)
    redirect_to suppliers_path, notice: "Fournisseur désactivé."
  end

  private

  def set_supplier
    @supplier = current_user.suppliers.find(params[:id])
  end

  def supplier_params
    params.require(:supplier).permit(:name)
  end

  def recalculate_products(product_ids)
    Product.where(id: product_ids).find_each do |product|
      Recalculations::Dispatcher.product_purchase_changed(nil, product: product)
    end
  end
end
