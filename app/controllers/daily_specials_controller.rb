# frozen_string_literal: true

class DailySpecialsController < ApplicationController
  before_action :set_daily_special, only: %i[update destroy]

  # GET /daily_specials
  def index
    @daily_special = current_user.daily_specials.build(entry_date: Date.today)
    @meats = current_user.daily_specials.meats.order(entry_date: :desc)
    @fishes = current_user.daily_specials.fishes.order(entry_date: :desc)
    @sides = current_user.daily_specials.sides.order(entry_date: :desc)
  end

  # POST /daily_specials
  def create
    @daily_special = current_user.daily_specials.build(daily_special_params)

    if @daily_special.save
      redirect_to daily_specials_path, notice: 'Plat du jour ajouté avec succès.'
    else
      @meats = current_user.daily_specials.meats.order(entry_date: :desc)
      @fishes = current_user.daily_specials.fishes.order(entry_date: :desc)
      @sides = current_user.daily_specials.sides.order(entry_date: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /daily_specials/:id
  def update
    if @daily_special.update(daily_special_params)
      redirect_to daily_specials_path, notice: 'Plat du jour mis à jour.'
    else
      @meats = current_user.daily_specials.meats.order(entry_date: :desc)
      @fishes = current_user.daily_specials.fishes.order(entry_date: :desc)
      @sides = current_user.daily_specials.sides.order(entry_date: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  # DELETE /daily_specials/:id
  def destroy
    @daily_special.destroy!
    redirect_to daily_specials_path, notice: 'Plat du jour supprimé.'
  end

  private

  def set_daily_special
    @daily_special = current_user.daily_specials.find(params[:id])
  end

  def daily_special_params
    params.require(:daily_special).permit(:item_name, :entry_date, :cost_per_kg, :category)
  end
end
