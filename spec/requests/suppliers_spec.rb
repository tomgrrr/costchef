# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Suppliers', type: :request do
  let(:user) { create(:user, email: 'chef@test.fr') }
  let(:other_user) { create(:user, email: 'other@test.fr') }

  describe 'GET /suppliers' do
    context 'non connecté' do
      it 'redirige vers login' do
        get suppliers_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'connecté sans abonnement' do
      let(:user) { create(:user, email: 'chef@test.fr', subscription_active: false) }

      before { sign_in user }

      it 'redirige vers subscription_required' do
        get suppliers_path
        expect(response).to redirect_to(subscription_required_path)
      end
    end

    context 'connecté avec abonnement' do
      before { sign_in user }

      it 'retourne HTTP 200' do
        get suppliers_path
        expect(response).to have_http_status(:ok)
      end

      it 'affiche ses fournisseurs' do
        supplier = create(:supplier, name: 'Metro', user: user)
        get suppliers_path
        expect(response.body).to include(supplier.name)
      end

      it "n'affiche pas les fournisseurs d'un autre user" do
        other_supplier = create(:supplier, name: 'Pomona', user: other_user)
        get suppliers_path
        expect(response.body).not_to include(other_supplier.name)
      end
    end
  end

  describe 'POST /suppliers' do
    before { sign_in user }

    context 'nom valide' do
      it 'crée le fournisseur et redirige vers index' do
        expect { post suppliers_path, params: { supplier: { name: 'Metro' } } }
          .to change(user.suppliers, :count).by(1)
        expect(response).to redirect_to(suppliers_path)
      end
    end

    context 'nom vide' do
      it 'retourne HTTP 422 sans créer' do
        expect { post suppliers_path, params: { supplier: { name: '' } } }
          .not_to change(Supplier, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'nom déjà pris par le même user' do
      before { create(:supplier, name: 'Metro', user: user) }

      it 'retourne HTTP 422' do
        expect { post suppliers_path, params: { supplier: { name: 'Metro' } } }
          .not_to change(Supplier, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "nom déjà pris par un autre user" do
      before { create(:supplier, name: 'Metro', user: other_user) }

      it 'crée le fournisseur (unicité scoped user_id)' do
        expect { post suppliers_path, params: { supplier: { name: 'Metro' } } }
          .to change(user.suppliers, :count).by(1)
        expect(response).to redirect_to(suppliers_path)
      end
    end
  end

  describe 'PATCH /suppliers/:id' do
    before { sign_in user }

    let!(:supplier) { create(:supplier, name: 'Metro', user: user) }

    context 'nom valide' do
      it 'met à jour et redirige vers index' do
        patch supplier_path(supplier), params: { supplier: { name: 'Pomona' } }
        expect(supplier.reload.name).to eq('Pomona')
        expect(response).to redirect_to(suppliers_path)
      end
    end

    context 'nom vide' do
      it 'retourne HTTP 422' do
        patch supplier_path(supplier), params: { supplier: { name: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(supplier.reload.name).to eq('Metro')
      end
    end

    context "supplier d'un autre user" do
      let!(:other_supplier) { create(:supplier, name: 'Pomona', user: other_user) }

      it 'retourne 404' do
        expect {
          patch supplier_path(other_supplier), params: { supplier: { name: 'Hack' } }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'POST /suppliers/:id/deactivate' do
    before { sign_in user }

    let!(:supplier) { create(:supplier, name: 'Metro', user: user) }
    let!(:product) { create(:product, name: 'Farine T55', user: user) }
    let!(:purchase) do
      create(:product_purchase, supplier: supplier, product: product, active: true)
    end

    it 'désactive le fournisseur' do
      post deactivate_supplier_path(supplier)
      expect(supplier.reload.active).to be(false)
    end

    it 'désactive tous ses achats actifs' do
      post deactivate_supplier_path(supplier)
      expect(purchase.reload.active).to be(false)
    end

    it 'appelle le Dispatcher pour chaque produit impacté' do
      allow(Recalculations::Dispatcher).to receive(:product_purchase_changed)
      post deactivate_supplier_path(supplier)
      expect(Recalculations::Dispatcher)
        .to have_received(:product_purchase_changed).with(nil, product: product)
    end

    it 'redirige vers index avec notice' do
      post deactivate_supplier_path(supplier)
      expect(response).to redirect_to(suppliers_path)
      expect(flash[:notice]).to be_present
    end
  end

  describe 'POST /suppliers/:id/activate' do
    before { sign_in user }

    let!(:supplier) { create(:supplier, name: 'Metro', user: user, active: false) }
    let!(:product) { create(:product, name: 'Farine T55', user: user) }
    let!(:purchase) do
      create(:product_purchase, supplier: supplier, product: product, active: false)
    end

    it 'active le fournisseur' do
      post activate_supplier_path(supplier)
      expect(supplier.reload.active).to be(true)
    end

    it 'ne modifie pas les achats' do
      post activate_supplier_path(supplier)
      expect(purchase.reload.active).to be(false)
    end

    it "n'appelle pas le Dispatcher" do
      allow(Recalculations::Dispatcher).to receive(:product_purchase_changed)
      post activate_supplier_path(supplier)
      expect(Recalculations::Dispatcher).not_to have_received(:product_purchase_changed)
    end

    it 'redirige vers index avec notice' do
      post activate_supplier_path(supplier)
      expect(response).to redirect_to(suppliers_path)
      expect(flash[:notice]).to be_present
    end
  end

  describe 'DELETE /suppliers/:id' do
    before { sign_in user }

    context 'sans achats' do
      let!(:supplier) { create(:supplier, name: 'Metro', user: user) }

      it 'supprime le fournisseur et redirige' do
        expect { delete supplier_path(supplier) }
          .to change(Supplier, :count).by(-1)
        expect(response).to redirect_to(suppliers_path)
        expect(flash[:notice]).to be_present
      end
    end

    context 'avec achats' do
      let!(:supplier) { create(:supplier, name: 'Metro', user: user) }
      let!(:product) { create(:product, name: 'Farine T55', user: user) }
      let!(:purchase) do
        create(:product_purchase, supplier: supplier, product: product)
      end

      it 'ne supprime pas et redirige avec alert' do
        expect { delete supplier_path(supplier) }
          .not_to change(Supplier, :count)
        expect(response).to redirect_to(suppliers_path)
        expect(flash[:alert]).to include('conditionnement')
      end
    end
  end

  describe 'DELETE /suppliers/:id?force=true' do
    before { sign_in user }

    let!(:supplier) { create(:supplier, name: 'Metro', user: user) }
    let!(:product) { create(:product, name: 'Farine T55', user: user) }
    let!(:purchase) do
      create(:product_purchase, supplier: supplier, product: product)
    end

    it 'supprime le fournisseur et ses achats' do
      expect { delete supplier_path(supplier, force: true) }
        .to change(Supplier, :count).by(-1)
        .and change(ProductPurchase, :count).by(-1)
    end

    it 'redirige avec notice' do
      delete supplier_path(supplier, force: true)
      expect(response).to redirect_to(suppliers_path)
      expect(flash[:notice]).to be_present
    end
  end

  describe 'isolation des données' do
    before { sign_in user }

    let!(:other_supplier) { create(:supplier, name: 'Pomona', user: other_user) }

    it 'retourne 404 pour deactivate' do
      expect {
        post deactivate_supplier_path(other_supplier)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'retourne 404 pour activate' do
      expect {
        post activate_supplier_path(other_supplier)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'retourne 404 pour destroy' do
      expect {
        delete supplier_path(other_supplier)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
