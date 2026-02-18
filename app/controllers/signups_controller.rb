# frozen_string_literal: true

class SignupsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :ensure_subscription!

  def new
    invitation = find_invitation
    unless invitation&.valid_for_signup?
      return redirect_to new_user_session_path,
                         alert: "Ce lien d'invitation est invalide ou expiré."
    end

    @invitation = invitation
    @user = User.new
  end

  def create
    invitation = find_invitation
    unless invitation&.valid_for_signup?
      return redirect_to new_user_session_path,
                         alert: "Ce lien d'invitation est invalide ou expiré."
    end

    @user = User.new(user_params)
    @user.email = invitation.email

    if @user.save
      invitation.mark_as_used!
      sign_in(@user)
      redirect_to root_path, notice: "Bienvenue sur CostChef !"
    else
      @invitation = invitation
      render :new, status: :unprocessable_entity
    end
  end

  private

  def find_invitation
    Invitation.find_by(token: params[:token])
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
