# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'StandardDeviations', type: :request do
  describe 'GET /ecarts-types' do
    context 'utilisateur non connecté' do
      it 'redirige vers la page de login' do
        get standard_deviations_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'utilisateur connecté sans abonnement actif' do
      let(:user) { create(:user, subscription_active: false) }

      before { sign_in user }

      it 'redirige vers subscription_required' do
        get standard_deviations_path
        expect(response).to redirect_to(subscription_required_path)
      end
    end

    context 'utilisateur connecté avec abonnement actif' do
      let(:user) { create(:user, subscription_active: true) }
      let(:supplier) { create(:supplier, user: user) }

      before { sign_in user }

      it 'retourne un succès' do
        get standard_deviations_path
        expect(response).to have_http_status(:success)
      end

      it 'affiche les produits avec CV triés par CV DESC' do
        product_high = create(:product, name: 'Beurre', user: user)
        product_low = create(:product, name: 'Farine', user: user)

        # Beurre : prix 2 et 10 → fort CV
        create(:product_purchase, product: product_high, supplier: supplier,
               package_quantity: 1, package_price: 2.0, package_unit: 'kg')
        create(:product_purchase, product: product_high, supplier: supplier,
               package_quantity: 1, package_price: 10.0, package_unit: 'kg')

        # Farine : prix 5 et 5.5 → faible CV
        create(:product_purchase, product: product_low, supplier: supplier,
               package_quantity: 1, package_price: 5.0, package_unit: 'kg')
        create(:product_purchase, product: product_low, supplier: supplier,
               package_quantity: 1, package_price: 5.5, package_unit: 'kg')

        get standard_deviations_path
        expect(response.body.index('Beurre')).to be < response.body.index('Farine')
      end

      it 'affiche les produits sans CV (N/A) en bas' do
        product_with_cv = create(:product, name: 'Beurre', user: user)
        product_without_cv = create(:product, name: 'Sucre', user: user)

        create(:product_purchase, product: product_with_cv, supplier: supplier,
               package_quantity: 1, package_price: 2.0, package_unit: 'kg')
        create(:product_purchase, product: product_with_cv, supplier: supplier,
               package_quantity: 1, package_price: 10.0, package_unit: 'kg')

        get standard_deviations_path
        expect(response.body.index('Beurre')).to be < response.body.index('Sucre')
        expect(response.body).to include('N/A')
      end

      it 'isole les produits par utilisateur' do
        other_user = create(:user, email: 'other@test.fr', subscription_active: true)
        create(:product, name: 'Produit Autre', user: other_user)

        get standard_deviations_path
        expect(response.body).not_to include('Produit Autre')
      end
    end
  end
end
