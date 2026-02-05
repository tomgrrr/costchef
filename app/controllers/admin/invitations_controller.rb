# frozen_string_literal: true

module Admin
  # PRD Module 1 : Gestion des invitations par les administrateurs
  # Permet de créer des invitations et d'envoyer automatiquement un email
  class InvitationsController < BaseController
    # GET /admin/invitations
    # Liste toutes les invitations avec leur statut
    def index
      @invitations = Invitation.includes(:created_by_admin).order(created_at: :desc)
    end

    # GET /admin/invitations/new
    # Formulaire de création d'une invitation
    def new
      @invitation = Invitation.new
    end

    # POST /admin/invitations
    # Crée l'invitation et envoie l'email automatiquement
    def create
      @invitation = Invitation.new(invitation_params)
      @invitation.created_by_admin = current_user

      if @invitation.save
        # Envoi automatique de l'email d'invitation
        InvitationMailer.invite_user(@invitation).deliver_later

        redirect_to admin_invitations_path,
                    notice: "Invitation envoyée à #{@invitation.email}"
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def invitation_params
      params.require(:invitation).permit(:email)
    end
  end
end
