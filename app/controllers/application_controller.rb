# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # PRD Module 1 : Authentification obligatoire pour tout l'application
  before_action :authenticate_user!

  # PRD Module 1 : Gating global par abonnement
  # Un utilisateur non abonné ne doit pas accéder à l'application
  before_action :ensure_subscription!

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    redirect_to root_path, alert: 'Ressource introuvable.'
  end

  # Vérifie que l'utilisateur a un abonnement actif
  # Redirige vers /subscription_required si subscription_active == false
  #
  # Exceptions (ne pas bloquer) :
  # - Contrôleurs Devise (login, logout, password reset, etc.)
  # - Page /subscription_required elle-même (gérée par skip_before_action)
  # - Namespace admin (géré par skip_before_action dans Admin::BaseController)
  def ensure_subscription!
    # Ne pas interférer avec Devise (login, logout, etc.)
    return if devise_controller?

    return unless user_signed_in?
    return if current_user.subscription_active?

    redirect_to subscription_required_path, alert: "Votre abonnement n'est pas actif."
  end

  # Devise : redirection vers la page de connexion après déconnexion
  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end
end
