# frozen_string_literal: true

class TraySizesController < ApplicationController
  before_action :set_tray_size, only: %i[edit update destroy]

  def index
    @tray_sizes = current_user.tray_sizes.order(:name)
  end

  def new
    @tray_size = current_user.tray_sizes.build
  end

  def create
    @tray_size = current_user.tray_sizes.build(tray_size_params)

    if @tray_size.save
      redirect_to tray_sizes_path, notice: "Format de barquette créé."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @tray_size.update(tray_size_params)
      redirect_to tray_sizes_path, notice: "Format de barquette mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tray_size.destroy!
    redirect_to tray_sizes_path, notice: "Format de barquette supprimé."
  end

  private

  def set_tray_size
    @tray_size = current_user.tray_sizes.find(params[:id])
  end

  def tray_size_params
    params.require(:tray_size).permit(:name, :price)
  end
end
