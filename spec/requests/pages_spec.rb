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

  describe 'GET /referentiel-pieces' do
    context 'utilisateur non connecté' do
      it 'redirige vers la page de login' do
        get referentiel_pieces_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'utilisateur connecté avec abonnement actif' do
      let(:user) { create(:user, subscription_active: true) }
      let(:other_user) { create(:user, email: 'other@example.com', subscription_active: true) }

      before { sign_in user }

      it 'retourne HTTP 200' do
        get referentiel_pieces_path
        expect(response).to have_http_status(:ok)
      end

      it 'affiche les produits piece de l utilisateur' do
        create(:product, :piece, name: 'Oeuf', user: user)
        get referentiel_pieces_path
        expect(response.body).to include('Oeuf')
      end

      it 'n affiche pas les produits kg ou litre' do
        create(:product, name: 'Farine', base_unit: 'kg', user: user)
        create(:product, name: 'Lait', base_unit: 'l', user: user)
        get referentiel_pieces_path
        expect(response.body).not_to include('Farine')
        expect(response.body).not_to include('Lait')
      end

      it 'n affiche pas les produits d un autre utilisateur' do
        create(:product, :piece, name: 'Avocat', user: other_user)
        get referentiel_pieces_path
        expect(response.body).not_to include('Avocat')
      end

      describe 'export CSV' do
        it 'retourne un fichier CSV avec les produits piece' do
          create(:product, :piece, name: 'Oeuf', unit_weight_kg: 0.06, avg_price_per_kg: 3.50, user: user)
          get referentiel_pieces_path(format: :csv)

          expect(response).to have_http_status(:ok)
          expect(response.content_type).to include('text/csv')

          lines = response.body.lines
          expect(lines[0]).to include('Nom;Poids unitaire (g);Poids unitaire (kg);Prix moyen')
          expect(lines[1]).to include('Oeuf;60;0.06;3.5')
        end
      end
    end
  end
end
