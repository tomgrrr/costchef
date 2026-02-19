# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Signups', type: :request do
  describe 'GET /signup' do
    context 'sans token' do
      it "redirige vers login avec un message d'alerte" do
        get signup_path
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be_present
      end
    end

    context 'token inexistant en base' do
      it "redirige vers login avec un message d'alerte" do
        get signup_path(token: 'token-qui-nexiste-pas')
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be_present
      end
    end

    context 'token expiré' do
      let(:invitation) { create(:invitation, :expired) }

      it "redirige vers login avec un message d'alerte" do
        get signup_path(token: invitation.token)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be_present
      end
    end

    context 'token déjà utilisé' do
      let(:invitation) { create(:invitation, :used) }

      it "redirige vers login avec un message d'alerte" do
        get signup_path(token: invitation.token)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be_present
      end
    end

    context 'token valide' do
      let(:invitation) { create(:invitation) }

      it 'retourne HTTP 200' do
        get signup_path(token: invitation.token)
        expect(response).to have_http_status(:ok)
      end

      it "affiche l'email de l'invitation dans le formulaire" do
        get signup_path(token: invitation.token)
        expect(response.body).to include(invitation.email)
      end
    end
  end

  describe 'POST /signup' do
    context 'token valide + données correctes' do
      let!(:invitation) { create(:invitation) }
      let(:valid_params) do
        {
          token: invitation.token,
          user: {
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it 'crée un nouvel utilisateur' do
        expect { post signup_path, params: valid_params }.to change(User, :count).by(1)
      end

      it "marque l'invitation comme utilisée" do
        post signup_path, params: valid_params
        invitation.reload
        expect(invitation.used_at).not_to be_nil
      end

      it 'redirige vers root_path' do
        post signup_path, params: valid_params
        expect(response).to redirect_to(root_path)
      end

      it "connecte l'utilisateur automatiquement" do
        post signup_path, params: valid_params
        follow_redirect!
        expect(request.env['warden'].user).not_to be_nil
      end
    end

    context 'token valide + mot de passe trop court' do
      let!(:invitation) { create(:invitation) }
      let(:short_password_params) do
        {
          token: invitation.token,
          user: {
            password: 'abc',
            password_confirmation: 'abc'
          }
        }
      end

      it "ne crée pas d'utilisateur" do
        expect { post signup_path, params: short_password_params }.not_to change(User, :count)
      end

      it 'retourne HTTP 422' do
        post signup_path, params: short_password_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'affiche les erreurs de validation' do
        post signup_path, params: short_password_params
        expect(response.body).to include('Password')
      end
    end

    context 'token valide + mots de passe non identiques' do
      let!(:invitation) { create(:invitation) }
      let(:mismatch_params) do
        {
          token: invitation.token,
          user: {
            password: 'password123',
            password_confirmation: 'different456'
          }
        }
      end

      it "ne crée pas d'utilisateur" do
        expect { post signup_path, params: mismatch_params }.not_to change(User, :count)
      end

      it 'retourne HTTP 422' do
        post signup_path, params: mismatch_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'token expiré' do
      let!(:invitation) { create(:invitation, :expired) }
      let(:params) do
        {
          token: invitation.token,
          user: {
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it "ne crée pas d'utilisateur" do
        expect { post signup_path, params: params }.not_to change(User, :count)
      end

      it 'redirige vers login' do
        post signup_path, params: params
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
