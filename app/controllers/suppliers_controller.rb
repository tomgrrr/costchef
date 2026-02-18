# frozen_string_literal: true

class SuppliersController < ApplicationController
  before_action :set_supplier, only: %i[show edit update deactivate destroy force_destroy]

  # GET /suppliers
  def index
    @suppliers = current_user.suppliers.order(:name)
  end

  # GET /suppliers/:id
  def show
    @product_purchases = @supplier.product_purchases.includes(:product)
  end

  # GET /suppliers/new
  def new
    @supplier = current_user.suppliers.build
  end

  # POST /suppliers
  def create
    @supplier = current_user.suppliers.build(supplier_params)

    if @supplier.save
      redirect_to suppliers_path, notice: 'Fournisseur créé avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /suppliers/:id/edit
  def edit; end

  # PATCH/PUT /suppliers/:id
  def update
    if @supplier.update(supplier_params)
      redirect_to supplier_path(@supplier), notice: 'Fournisseur mis à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # PATCH /suppliers/:id/deactivate
  def deactivate
    if @supplier.active?
      @supplier.deactivate!
      redirect_to supplier_path(@supplier), notice: 'Fournisseur désactivé.'
    else
      @supplier.activate!
      redirect_to supplier_path(@supplier), notice: 'Fournisseur réactivé.'
    end
  end

  # DELETE /suppliers/:id
  def destroy
    @supplier.destroy!
    redirect_to suppliers_path, notice: 'Fournisseur supprimé avec succès.'
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to supplier_path(@supplier),
                alert: 'Impossible de supprimer ce fournisseur car il a des achats associés. ' \
                       'Utilisez la suppression forcée pour supprimer le fournisseur et ses achats.'
  end

  # DELETE /suppliers/:id/force_destroy
  def force_destroy
    impacted_ids = @supplier.force_destroy!
    Recalculations::Dispatcher.supplier_force_destroyed(impacted_ids)
    redirect_to suppliers_path, notice: 'Fournisseur et ses achats supprimés. Les prix ont été recalculés.'
  end

  private

  def set_supplier
    @supplier = current_user.suppliers.find(params[:id])
  end

  def supplier_params
    params.require(:supplier).permit(:name)
  end
end
