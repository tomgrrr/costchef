# frozen_string_literal: true

# PRD Module 1 : Inscription via lien sécurisé
# Contrôleur public pour l'inscription via token d'invitation
class SignupsController < ApplicationController
  # Pas d'authentification requise pour s'inscrire
  skip_before_action :authenticate_user!
  skip_before_action :ensure_subscription!

  before_action :find_and_validate_invitation

  # GET /signup?token=xxx
  # Affiche le formulaire d'inscription si l'invitation est valide
  def new
    @user = User.new(email: @invitation.email)
  end

  # POST /signup
  # Crée le compte utilisateur et marque l'invitation comme utilisée
  def create
    @user = User.new(user_params)
    @user.email = @invitation.email # Force l'email de l'invitation
    @user.subscription_active = false
    @user.admin = false

    if @user.save
      # Marque l'invitation comme utilisée
      @invitation.mark_as_used!

      # Connexion automatique
      sign_in(@user)

      # Redirige vers la page d'abonnement requis (gating actif)
      redirect_to root_path, notice: 'Compte créé avec succès. Contactez un administrateur pour activer votre abonnement.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Recherche et valide l'invitation via le token
  def find_and_validate_invitation
    @invitation = Invitation.find_by(token: params[:token])

    if @invitation.nil?
      redirect_to new_user_session_path, alert: 'Lien d\'invitation invalide.'
    elsif !@invitation.valid_for_signup?
      if @invitation.used_at.present?
        redirect_to new_user_session_path, alert: 'Cette invitation a déjà été utilisée.'
      else
        redirect_to new_user_session_path, alert: 'Cette invitation a expiré.'
      end
    end
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation, :first_name, :last_name, :company_name)
  end
end
