# frozen_string_literal: true

# Manages daily special entries (meat, fish, side) for cost tracking.
class DailySpecialsController < ApplicationController
  def index
    load_entries
    load_averages
  end

  def create
    @daily_special = current_user.daily_specials.build(daily_special_params)
    if @daily_special.save
      redirect_to daily_specials_path, notice: 'Entrée ajoutée.'
    else
      redirect_to daily_specials_path, alert: @daily_special.errors.full_messages.join(', ')
    end
  end

  def update
    @daily_special = current_user.daily_specials.find(params[:id])
    if @daily_special.update(daily_special_params)
      redirect_to daily_specials_path, notice: 'Entrée mise à jour.'
    else
      redirect_to daily_specials_path, alert: @daily_special.errors.full_messages.join(', ')
    end
  end

  def destroy
    current_user.daily_specials.find(params[:id]).destroy!
    redirect_to daily_specials_path, notice: 'Entrée supprimée.'
  end

  private

  def load_entries
    @meats  = current_user.daily_specials.meats.order(entry_date: :desc)
    @fishes = current_user.daily_specials.fishes.order(entry_date: :desc)
    @sides  = current_user.daily_specials.sides.order(entry_date: :desc)
  end

  def load_averages
    @meat_average = current_user.daily_specials.meat_average
    @fish_average = current_user.daily_specials.fish_average
    @side_average = current_user.daily_specials.side_average
  end

  def daily_special_params
    params.require(:daily_special).permit(:category, :entry_date, :item_name, :cost_per_kg)
  end
end
