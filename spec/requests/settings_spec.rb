# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings', type: :request do
  describe 'GET /settings' do
    context 'utilisateur non connecté' do
      it 'redirige vers la page de login' do
        get settings_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'utilisateur connecté sans abonnement actif' do
      let(:user) { create(:user, subscription_active: false) }

      before { sign_in user }

      it 'redirige vers subscription_required' do
        get settings_path
        expect(response).to redirect_to(subscription_required_path)
      end
    end

    context 'utilisateur connecté avec abonnement actif' do
      let(:user) { create(:user, subscription_active: true) }

      before { sign_in user }

      it 'redirige vers tray_sizes_path' do
        get settings_path
        expect(response).to redirect_to(tray_sizes_path)
      end
    end
  end

  describe 'PATCH /settings' do
    context 'utilisateur non connecté' do
      it 'redirige vers la page de login' do
        patch settings_path, params: { user: { markup_coefficient: 2.5 } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'utilisateur connecté avec abonnement actif' do
      let(:user) { create(:user, subscription_active: true, markup_coefficient: 1.0) }

      before { sign_in user }

      it 'met à jour le markup_coefficient avec une valeur valide' do
        patch settings_path, params: { user: { markup_coefficient: 2.5 } }
        expect(user.reload.markup_coefficient).to eq(2.5)
      end

      it 'redirige vers tray_sizes_path avec notice' do
        patch settings_path, params: { user: { markup_coefficient: 2.5 } }
        expect(response).to redirect_to(tray_sizes_path)
        expect(flash[:notice]).to include('2.5')
      end

      it 'refuse une valeur invalide (< 0.1)' do
        patch settings_path, params: { user: { markup_coefficient: 0.05 } }
        expect(user.reload.markup_coefficient).to eq(1.0)
        expect(response).to redirect_to(tray_sizes_path)
        expect(flash[:alert]).to be_present
      end

      it 'ignore les paramètres non autorisés (admin)' do
        patch settings_path, params: { user: { markup_coefficient: 2.0, admin: true } }
        user.reload
        expect(user.markup_coefficient).to eq(2.0)
        expect(user.admin).to be(false)
      end
    end
  end
end
