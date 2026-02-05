# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:update]

    # GET /admin/users
    # PRD Module 1 : Liste tous les utilisateurs
    # Affiche : email, subscription_active, dates, admin
    def index
      @users = User.order(created_at: :desc)
    end

    # PATCH/PUT /admin/users/:id
    # PRD Module 1 : Permet d'activer/désactiver subscription_active
    # et de définir subscription_started_at / subscription_expires_at
    def update
      if @user.update(user_params)
        redirect_to admin_users_path, notice: "Utilisateur mis à jour avec succès."
      else
        redirect_to admin_users_path, alert: "Erreur lors de la mise à jour."
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    # Seuls les champs liés à l'abonnement sont modifiables par l'admin
    # Pas de création/suppression d'utilisateur dans cette étape
    def user_params
      params.require(:user).permit(
        :subscription_active,
        :subscription_started_at,
        :subscription_expires_at,
        :subscription_notes
      )
    end
  end
end
