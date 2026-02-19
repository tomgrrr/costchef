# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ProductPurchases', type: :request do
  let(:user) { create(:user, email: 'chef@test.fr') }
  let(:other_user) { create(:user, email: 'other@test.fr') }
  let(:supplier) { create(:supplier, name: 'Metro', user: user) }
  let(:product) { create(:product, name: 'Farine T55', user: user) }

  let(:turbo_headers) { { 'Accept' => 'text/vnd.turbo-stream.html' } }

  before do
    sign_in user
    allow(ProductPurchases::PricePerKgCalculator).to receive(:call).and_call_original
    allow(Recalculations::Dispatcher).to receive(:product_purchase_changed)
  end

  describe 'POST /product_purchases' do
    let(:valid_params) do
      {
        product_id: product.id,
        product_purchase: {
          supplier_id: supplier.id,
          package_quantity: 25,
          package_unit: 'kg',
          package_price: 15.0
        }
      }
    end

    context 'données valides' do
      it 'crée le product_purchase' do
        expect { post product_purchases_path, params: valid_params, headers: turbo_headers }
          .to change(ProductPurchase, :count).by(1)
      end

      it 'appelle PricePerKgCalculator' do
        post product_purchases_path, params: valid_params, headers: turbo_headers
        expect(ProductPurchases::PricePerKgCalculator).to have_received(:call)
      end

      it 'appelle Dispatcher.product_purchase_changed' do
        post product_purchases_path, params: valid_params, headers: turbo_headers
        expect(Recalculations::Dispatcher)
          .to have_received(:product_purchase_changed).with(an_instance_of(ProductPurchase))
      end

      it 'retourne une réponse turbo_stream HTTP 200' do
        post product_purchases_path, params: valid_params, headers: turbo_headers
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('turbo-stream')
        expect(response.body).to include(product.name)
      end
    end

    context 'package_quantity manquant' do
      it 'ne crée pas et retourne turbo_stream HTTP 200' do
        invalid_params = valid_params.deep_merge(product_purchase: { package_quantity: nil })
        expect { post product_purchases_path, params: invalid_params, headers: turbo_headers }
          .not_to change(ProductPurchase, :count)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('turbo-stream')
      end
    end

    context "supplier_id d'un autre user" do
      let(:other_supplier) { create(:supplier, name: 'Pomona', user: other_user) }

      it 'redirige vers root_path (RecordNotFound)' do
        params = valid_params.deep_merge(product_purchase: { supplier_id: other_supplier.id })
        post product_purchases_path, params: params, headers: turbo_headers
        expect(response).to redirect_to(root_path)
      end
    end

    context "product_id d'un autre user" do
      let(:other_product) { create(:product, name: 'Beurre', user: other_user) }

      it 'redirige vers root_path (RecordNotFound)' do
        params = valid_params.merge(product_id: other_product.id)
        post product_purchases_path, params: params, headers: turbo_headers
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH /product_purchases/:id' do
    let!(:purchase) do
      create(:product_purchase, product: product, supplier: supplier)
    end

    let(:update_params) do
      {
        product_id: product.id,
        product_purchase: {
          supplier_id: supplier.id,
          package_quantity: 50,
          package_unit: 'kg',
          package_price: 25.0
        }
      }
    end

    context 'données valides' do
      it 'appelle PricePerKgCalculator' do
        patch product_purchase_path(purchase), params: update_params, headers: turbo_headers
        expect(ProductPurchases::PricePerKgCalculator).to have_received(:call)
      end

      it 'appelle Dispatcher.product_purchase_changed' do
        patch product_purchase_path(purchase), params: update_params, headers: turbo_headers
        expect(Recalculations::Dispatcher)
          .to have_received(:product_purchase_changed).with(an_instance_of(ProductPurchase))
      end

      it 'retourne une réponse turbo_stream HTTP 200' do
        patch product_purchase_path(purchase), params: update_params, headers: turbo_headers
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('turbo-stream')
      end
    end

    context 'données invalides (package_quantity nil)' do
      it 'retourne turbo_stream HTTP 200 et ne dispatch pas' do
        invalid_params = update_params.deep_merge(product_purchase: { package_quantity: nil })
        patch product_purchase_path(purchase), params: invalid_params, headers: turbo_headers
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('turbo-stream')
        expect(Recalculations::Dispatcher).not_to have_received(:product_purchase_changed)
      end
    end

    context "purchase d'un autre user" do
      let(:other_product) { create(:product, name: 'Beurre', user: other_user) }
      let(:other_supplier) { create(:supplier, name: 'Pomona', user: other_user) }
      let!(:other_purchase) do
        create(:product_purchase, product: other_product, supplier: other_supplier)
      end

      it 'redirige vers root_path' do
        patch product_purchase_path(other_purchase),
              params: { product_id: other_product.id, product_purchase: { package_quantity: 10 } },
              headers: turbo_headers
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'DELETE /product_purchases/:id' do
    let!(:purchase) do
      create(:product_purchase, product: product, supplier: supplier)
    end

    context 'purchase du user connecté' do
      it 'supprime le purchase' do
        expect {
          delete product_purchase_path(purchase),
                 params: { product_id: product.id },
                 headers: turbo_headers
        }.to change(ProductPurchase, :count).by(-1)
      end

      it 'appelle Dispatcher avec nil et product' do
        delete product_purchase_path(purchase),
               params: { product_id: product.id },
               headers: turbo_headers
        expect(Recalculations::Dispatcher)
          .to have_received(:product_purchase_changed)
          .with(nil, product: an_instance_of(Product))
      end

      it 'retourne une réponse turbo_stream HTTP 200' do
        delete product_purchase_path(purchase),
               params: { product_id: product.id },
               headers: turbo_headers
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('turbo-stream')
      end
    end

    context "purchase d'un autre user" do
      let(:other_product) { create(:product, name: 'Beurre', user: other_user) }
      let(:other_supplier) { create(:supplier, name: 'Pomona', user: other_user) }
      let!(:other_purchase) do
        create(:product_purchase, product: other_product, supplier: other_supplier)
      end

      it 'redirige vers root_path' do
        delete product_purchase_path(other_purchase),
               params: { product_id: other_product.id },
               headers: turbo_headers
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'POST /product_purchases/:id/toggle_active' do
    let!(:purchase) do
      create(:product_purchase, product: product, supplier: supplier, active: true)
    end

    context 'purchase actif' do
      it 'passe à false' do
        post toggle_active_product_purchase_path(purchase),
             params: { product_id: product.id },
             headers: turbo_headers
        expect(purchase.reload.active).to be(false)
      end
    end

    context 'purchase inactif' do
      before { purchase.update!(active: false) }

      it 'passe à true' do
        post toggle_active_product_purchase_path(purchase),
             params: { product_id: product.id },
             headers: turbo_headers
        expect(purchase.reload.active).to be(true)
      end
    end

    it 'appelle Dispatcher avec nil et product' do
      post toggle_active_product_purchase_path(purchase),
           params: { product_id: product.id },
           headers: turbo_headers
      expect(Recalculations::Dispatcher)
        .to have_received(:product_purchase_changed)
        .with(nil, product: an_instance_of(Product))
    end

    it 'retourne une réponse turbo_stream HTTP 200' do
      post toggle_active_product_purchase_path(purchase),
           params: { product_id: product.id },
           headers: turbo_headers
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('turbo-stream')
    end

    context "purchase d'un autre user" do
      let(:other_product) { create(:product, name: 'Beurre', user: other_user) }
      let(:other_supplier) { create(:supplier, name: 'Pomona', user: other_user) }
      let!(:other_purchase) do
        create(:product_purchase, product: other_product, supplier: other_supplier)
      end

      it 'redirige vers root_path' do
        post toggle_active_product_purchase_path(other_purchase),
             params: { product_id: other_product.id },
             headers: turbo_headers
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
