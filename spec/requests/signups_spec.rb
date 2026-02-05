# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Signups', type: :request do
  let!(:admin) { create(:user, :admin) }
  let!(:invitation) { create(:invitation, created_by_admin: admin) }

  describe 'GET /signup' do
    context 'with valid token' do
      it 'displays the signup form' do
        get signup_path(token: invitation.token)
        expect(response).to have_http_status(:ok)
      end

      it 'pre-fills the email from invitation' do
        get signup_path(token: invitation.token)
        expect(response.body).to include(invitation.email)
      end
    end

    context 'with invalid token' do
      it 'redirects to login page' do
        get signup_path(token: 'invalid-token')
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'sets an error flash message' do
        get signup_path(token: 'invalid-token')
        expect(flash[:alert]).to include('invalide')
      end
    end

    context 'with expired token' do
      let(:expired_invitation) { create(:invitation, :expired, created_by_admin: admin) }

      it 'redirects to login page' do
        get signup_path(token: expired_invitation.token)
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'sets expiration flash message' do
        get signup_path(token: expired_invitation.token)
        expect(flash[:alert]).to include('expiré')
      end
    end

    context 'with used token' do
      let(:used_invitation) { create(:invitation, :used, created_by_admin: admin) }

      it 'redirects to login page' do
        get signup_path(token: used_invitation.token)
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'sets already used flash message' do
        get signup_path(token: used_invitation.token)
        expect(flash[:alert]).to include('déjà été utilisée')
      end
    end

    context 'without token' do
      it 'redirects to login page' do
        get signup_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST /signup' do
    let(:valid_user_params) do
      {
        user: {
          password: 'password123',
          password_confirmation: 'password123',
          first_name: 'Jean',
          last_name: 'Dupont',
          company_name: 'Restaurant Test'
        }
      }
    end

    context 'with valid token and params' do
      it 'creates a new user' do
        expect {
          post signup_path(token: invitation.token), params: valid_user_params
        }.to change(User, :count).by(1)
      end

      it 'creates user with subscription_active = false' do
        post signup_path(token: invitation.token), params: valid_user_params
        user = User.find_by(email: invitation.email)
        expect(user.subscription_active).to be false
      end

      it 'creates user with admin = false' do
        post signup_path(token: invitation.token), params: valid_user_params
        user = User.find_by(email: invitation.email)
        expect(user.admin).to be false
      end

      it 'forces email from invitation (ignores user-provided email)' do
        params_with_different_email = valid_user_params.deep_merge(user: { email: 'hacker@evil.com' })
        post signup_path(token: invitation.token), params: params_with_different_email
        expect(User.exists?(email: 'hacker@evil.com')).to be false
        expect(User.exists?(email: invitation.email)).to be true
      end

      it 'marks invitation as used' do
        post signup_path(token: invitation.token), params: valid_user_params
        expect(invitation.reload.used_at).to be_present
      end

      it 'signs in the user automatically' do
        post signup_path(token: invitation.token), params: valid_user_params
        follow_redirect!
        expect(controller.current_user).to be_present
      end

      it 'redirects to root path' do
        post signup_path(token: invitation.token), params: valid_user_params
        expect(response).to redirect_to(root_path)
      end
    end

    context 'with invalid params' do
      it 'does not create user with mismatched passwords' do
        invalid_params = valid_user_params.deep_merge(user: { password_confirmation: 'different' })
        expect {
          post signup_path(token: invitation.token), params: invalid_params
        }.not_to change(User, :count)
      end

      it 'does not create user with too short password' do
        invalid_params = valid_user_params.deep_merge(user: { password: '123', password_confirmation: '123' })
        expect {
          post signup_path(token: invitation.token), params: invalid_params
        }.not_to change(User, :count)
      end

      it 're-renders the signup form' do
        invalid_params = valid_user_params.deep_merge(user: { password_confirmation: 'different' })
        post signup_path(token: invitation.token), params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not mark invitation as used' do
        invalid_params = valid_user_params.deep_merge(user: { password_confirmation: 'different' })
        post signup_path(token: invitation.token), params: invalid_params
        expect(invitation.reload.used_at).to be_nil
      end
    end

    context 'with invalid token' do
      it 'redirects to login page' do
        post signup_path(token: 'invalid-token'), params: valid_user_params
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not create user' do
        expect {
          post signup_path(token: 'invalid-token'), params: valid_user_params
        }.not_to change(User, :count)
      end
    end

    context 'with expired token' do
      let!(:expired_invitation) { create(:invitation, :expired, created_by_admin: admin) }

      it 'redirects to login page' do
        post signup_path(token: expired_invitation.token), params: valid_user_params
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not create user' do
        expect {
          post signup_path(token: expired_invitation.token), params: valid_user_params
        }.not_to change(User, :count)
      end
    end

    context 'with used token' do
      let!(:used_invitation) { create(:invitation, :used, created_by_admin: admin) }

      it 'redirects to login page' do
        post signup_path(token: used_invitation.token), params: valid_user_params
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not create user' do
        expect {
          post signup_path(token: used_invitation.token), params: valid_user_params
        }.not_to change(User, :count)
      end
    end
  end
end
