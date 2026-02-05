# frozen_string_literal: true

# PRD Module 1 : Email d'invitation pour inscription
class InvitationMailer < ApplicationMailer
  # Envoie l'email d'invitation avec le lien sécurisé
  def invite_user(invitation)
    @invitation = invitation
    @signup_url = signup_url(token: invitation.token)

    mail(
      to: invitation.email,
      subject: 'Invitation à rejoindre CostChef'
    )
  end
end
