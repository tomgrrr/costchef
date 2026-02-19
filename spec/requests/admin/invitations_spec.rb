# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Invitations', type: :request do
  let(:admin) { create(:user, email: 'admin@test.fr', admin: true) }
  let(:user)  { create(:user, email: 'user@test.fr', admin: false) }

  describe 'GET /admin/invitations' do
    context 'non connecté' do
      it 'redirige vers login' do
        get admin_invitations_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'connecté en tant qu utilisateur simple' do
      before { sign_in user }

      it 'redirige vers root avec alert' do
        get admin_invitations_path
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end

    context 'connecté en tant qu admin' do
      before { sign_in admin }

      it 'retourne HTTP 200' do
        get admin_invitations_path
        expect(response).to have_http_status(:ok)
      end

      it 'affiche les invitations existantes' do
        inv1 = create(:invitation, email: 'alice@test.fr', created_by_admin: admin)
        inv2 = create(:invitation, email: 'bob@test.fr', created_by_admin: admin)
        get admin_invitations_path
        expect(response.body).to include(inv1.email)
        expect(response.body).to include(inv2.email)
      end
    end
  end

  describe 'GET /admin/invitations/new' do
    context 'non connecté' do
      it 'redirige vers login' do
        get new_admin_invitation_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'utilisateur simple' do
      before { sign_in user }

      it 'redirige vers root' do
        get new_admin_invitation_path
        expect(response).to redirect_to(root_path)
      end
    end

    context 'admin' do
      before { sign_in admin }

      it 'retourne HTTP 200' do
        get new_admin_invitation_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /admin/invitations' do
    context 'admin + email valide' do
      before { sign_in admin }

      let(:valid_params) { { invitation: { email: 'nouveau@test.fr' } } }

      it 'crée une invitation' do
        expect { post admin_invitations_path, params: valid_params }.to change(Invitation, :count).by(1)
      end

      it 'redirige vers admin_invitations_path' do
        post admin_invitations_path, params: valid_params
        expect(response).to redirect_to(admin_invitations_path)
      end

      it 'envoie un email' do
        expect { post admin_invitations_path, params: valid_params }
          .to have_enqueued_mail(InvitationMailer, :invite_user)
      end
    end

    context 'admin + email déjà utilisé par un utilisateur existant' do
      before { sign_in admin }

      let(:duplicate_params) { { invitation: { email: user.email } } }

      it "ne crée pas d'invitation" do
        expect { post admin_invitations_path, params: duplicate_params }.not_to change(Invitation, :count)
      end

      it 'retourne HTTP 422' do
        post admin_invitations_path, params: duplicate_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'utilisateur simple' do
      before { sign_in user }

      it "redirige vers root sans créer d'invitation" do
        expect { post admin_invitations_path, params: { invitation: { email: 'x@test.fr' } } }
          .not_to change(Invitation, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
