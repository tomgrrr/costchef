# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  describe 'GET /' do
    context 'utilisateur non connecté' do
      it 'redirige vers la page de login' do
        get root_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'utilisateur connecté sans abonnement actif' do
      let(:user) { create(:user, subscription_active: false) }

      before do
        sign_in user
      end

      it 'redirige vers subscription_required' do
        get root_path
        expect(response).to redirect_to(subscription_required_path)
      end
    end

    context 'utilisateur connecté avec abonnement actif' do
      let(:user) { create(:user, subscription_active: true) }

      before do
        sign_in user
      end

      it 'retourne HTTP 200' do
        get root_path
        expect(response).to have_http_status(:ok)
      end

      it 'affiche le compteur de produits' do
        create(:product, name: 'Farine T55', user: user)
        create(:product, name: 'Beurre', user: user)
        get root_path
        expect(response.body).to include('2')
      end

      it 'affiche le compteur de recettes' do
        create(:recipe, user: user)
        get root_path
        expect(response.body).to include('1')
      end
    end
  end

  describe 'GET /subscription_required' do
    context 'utilisateur non connecté' do
      it 'redirige vers login' do
        get subscription_required_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'utilisateur connecté sans abonnement' do
      let(:user) { create(:user, subscription_active: false) }

      before do
        sign_in user
      end

      it 'retourne HTTP 200' do
        get subscription_required_path
        expect(response).to have_http_status(:ok)
      end
    end

    context 'utilisateur connecté avec abonnement actif' do
      let(:user) { create(:user, subscription_active: true) }

      before do
        sign_in user
      end

      it 'retourne HTTP 200 (la page reste accessible)' do
        get subscription_required_path
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
