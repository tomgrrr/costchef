# frozen_string_literal: true

class SettingsController < ApplicationController
  def edit
    redirect_to tray_sizes_path
  end

  def update
    if current_user.update(markup_params)
      redirect_to tray_sizes_path,
                  notice: "Coefficient mis à jour (×#{current_user.markup_coefficient})."
    else
      redirect_to tray_sizes_path,
                  alert: current_user.errors.full_messages.join(", ")
    end
  end

  private

  def markup_params
    params.require(:user).permit(:markup_coefficient)
  end
end
