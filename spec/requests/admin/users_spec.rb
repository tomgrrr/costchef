# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Users', type: :request do
  let(:admin) { create(:user, email: 'admin@test.fr', admin: true) }
  let(:user)  { create(:user, email: 'user@test.fr', admin: false) }

  describe 'GET /admin/users' do
    context 'non connecté' do
      it 'redirige vers login' do
        get admin_users_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'utilisateur simple' do
      before { sign_in user }

      it 'redirige vers root' do
        get admin_users_path
        expect(response).to redirect_to(root_path)
      end
    end

    context 'admin' do
      before { sign_in admin }

      it 'retourne HTTP 200' do
        get admin_users_path
        expect(response).to have_http_status(:ok)
      end

      it 'affiche tous les utilisateurs' do
        user1 = create(:user, email: 'alice@test.fr')
        user2 = create(:user, email: 'bob@test.fr')
        get admin_users_path
        expect(response.body).to include(admin.email)
        expect(response.body).to include(user1.email)
        expect(response.body).to include(user2.email)
      end

      it 'affiche les badges abonnement' do
        create(:user, email: 'actif@test.fr', subscription_active: true)
        create(:user, email: 'inactif@test.fr', subscription_active: false)
        get admin_users_path
        expect(response.body).to include('Actif')
        expect(response.body).to include('Inactif')
      end
    end
  end

  describe 'PATCH /admin/users/:id' do
    context 'admin modifie subscription_active' do
      before { sign_in admin }

      let(:target_user) { create(:user, email: 'target@test.fr', subscription_active: false) }

      it 'met à jour subscription_active à true' do
        patch admin_user_path(target_user), params: { user: { subscription_active: true } }
        target_user.reload
        expect(target_user.subscription_active).to be true
      end

      it 'redirige vers admin_users_path' do
        patch admin_user_path(target_user), params: { user: { subscription_active: true } }
        expect(response).to redirect_to(admin_users_path)
      end
    end

    context 'admin modifie subscription_notes' do
      before { sign_in admin }

      let(:target_user) { create(:user, email: 'target@test.fr') }

      it 'met à jour les notes' do
        patch admin_user_path(target_user), params: { user: { subscription_notes: 'Client fidèle' } }
        target_user.reload
        expect(target_user.subscription_notes).to eq('Client fidèle')
      end
    end

    context 'utilisateur simple' do
      before { sign_in user }

      let(:target_user) { create(:user, email: 'target@test.fr', subscription_active: false) }

      it 'redirige vers root sans modifier le user' do
        patch admin_user_path(target_user), params: { user: { subscription_active: true } }
        expect(response).to redirect_to(root_path)
        target_user.reload
        expect(target_user.subscription_active).to be false
      end
    end
  end
end
