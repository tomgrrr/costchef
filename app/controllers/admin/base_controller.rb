# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    # PRD Module 1 : Accès uniquement aux utilisateurs avec admin == true
    before_action :require_admin!

    # Le namespace admin est exclu du gating par abonnement
    # Un admin doit pouvoir gérer les utilisateurs même sans abonnement
    skip_before_action :ensure_subscription!

    private

    def require_admin!
      return if current_user&.admin?

      redirect_to root_path, alert: "Accès réservé aux administrateurs."
    end
  end
end
