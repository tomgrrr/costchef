# frozen_string_literal: true

class PagesController < ApplicationController
  # PRD Module 1 : Page statique "Abonnement requis"
  # Exceptions : cette page doit être accessible sans abonnement actif
  skip_before_action :ensure_subscription!, only: [:subscription_required]

  # GET /
  # Page d'accueil temporaire (sera remplacée par le dashboard)
  def home
  end

  # GET /subscription_required
  # Affiche un message indiquant que l'abonnement est inactif
  def subscription_required
    # Redirige vers la racine si l'utilisateur a déjà un abonnement actif
    redirect_to root_path if current_user.subscription_active?
  end
end
