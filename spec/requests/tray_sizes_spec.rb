# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TraySizes', type: :request do
  let(:user) { create(:user, email: 'chef@test.fr') }
  let(:other_user) { create(:user, email: 'other@test.fr') }

  describe 'GET /tray_sizes' do
    context 'non connecté' do
      it 'redirige vers login' do
        get tray_sizes_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'connecté sans abonnement' do
      let(:user) { create(:user, email: 'chef@test.fr', subscription_active: false) }

      before { sign_in user }

      it 'redirige vers subscription_required' do
        get tray_sizes_path
        expect(response).to redirect_to(subscription_required_path)
      end
    end

    context 'connecté avec abonnement' do
      before { sign_in user }

      it 'retourne HTTP 200' do
        get tray_sizes_path
        expect(response).to have_http_status(:ok)
      end

      it 'affiche ses tray_sizes' do
        tray_size = create(:tray_size, name: 'Barquette 500g', user: user)
        get tray_sizes_path
        expect(response.body).to include(tray_size.name)
      end

      it "n'affiche pas les tray_sizes d'un autre user" do
        other_tray = create(:tray_size, name: 'Barquette 1kg', user: other_user)
        get tray_sizes_path
        expect(response.body).not_to include(other_tray.name)
      end
    end
  end

  describe 'GET /tray_sizes/new' do
    before { sign_in user }

    it 'retourne HTTP 200' do
      get new_tray_size_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /tray_sizes' do
    before { sign_in user }

    context 'params valides' do
      it 'crée le tray_size et redirige vers index' do
        expect { post tray_sizes_path, params: { tray_size: { name: 'Barquette 500g', price: 0.35 } } }
          .to change(user.tray_sizes, :count).by(1)
        expect(response).to redirect_to(tray_sizes_path)
        expect(flash[:notice]).to be_present
      end
    end

    context 'nom vide' do
      it 'retourne HTTP 422 sans créer' do
        expect { post tray_sizes_path, params: { tray_size: { name: '', price: 0.35 } } }
          .not_to change(TraySize, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'nom déjà pris par le même user' do
      before { create(:tray_size, name: 'Barquette 500g', user: user) }

      it 'retourne HTTP 422' do
        expect { post tray_sizes_path, params: { tray_size: { name: 'Barquette 500g', price: 0.50 } } }
          .not_to change(TraySize, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "nom déjà pris par un autre user" do
      before { create(:tray_size, name: 'Barquette 500g', user: other_user) }

      it 'crée le tray_size (unicité scoped user_id)' do
        expect { post tray_sizes_path, params: { tray_size: { name: 'Barquette 500g', price: 0.35 } } }
          .to change(user.tray_sizes, :count).by(1)
        expect(response).to redirect_to(tray_sizes_path)
      end
    end
  end

  describe 'GET /tray_sizes/:id/edit' do
    before { sign_in user }

    it 'retourne HTTP 200 pour son propre tray_size' do
      tray_size = create(:tray_size, user: user)
      get edit_tray_size_path(tray_size)
      expect(response).to have_http_status(:ok)
    end

    it "redirige vers root_path pour un tray_size d'un autre user" do
      other_tray = create(:tray_size, name: 'Barquette 1kg', user: other_user)
      get edit_tray_size_path(other_tray)
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'PATCH /tray_sizes/:id' do
    before { sign_in user }

    let!(:tray_size) { create(:tray_size, name: 'Barquette 500g', price: 0.35, user: user) }

    context 'params valides' do
      it 'met à jour et redirige vers index' do
        patch tray_size_path(tray_size), params: { tray_size: { name: 'Barquette 1kg', price: 0.50 } }
        expect(tray_size.reload.name).to eq('Barquette 1kg')
        expect(tray_size.reload.price).to eq(0.50)
        expect(response).to redirect_to(tray_sizes_path)
        expect(flash[:notice]).to be_present
      end
    end

    context 'nom vide' do
      it 'retourne HTTP 422' do
        patch tray_size_path(tray_size), params: { tray_size: { name: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(tray_size.reload.name).to eq('Barquette 500g')
      end
    end

    context "tray_size d'un autre user" do
      let!(:other_tray) { create(:tray_size, name: 'Barquette 1kg', user: other_user) }

      it 'redirige vers root_path' do
        patch tray_size_path(other_tray), params: { tray_size: { name: 'Hack' } }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'DELETE /tray_sizes/:id' do
    before { sign_in user }

    context 'sans recettes associées' do
      let!(:tray_size) { create(:tray_size, name: 'Barquette 500g', user: user) }

      it 'supprime le tray_size et redirige' do
        expect { delete tray_size_path(tray_size) }
          .to change(TraySize, :count).by(-1)
        expect(response).to redirect_to(tray_sizes_path)
        expect(flash[:notice]).to be_present
      end
    end

    context 'avec recettes associées' do
      let!(:tray_size) { create(:tray_size, name: 'Barquette 500g', user: user) }
      let!(:recipe) { create(:recipe, name: 'Pâte brisée', user: user, tray_size: tray_size, has_tray: true) }

      it 'supprime le tray_size et nullifie les recettes' do
        expect { delete tray_size_path(tray_size) }
          .to change(TraySize, :count).by(-1)

        recipe.reload
        expect(recipe.tray_size_id).to be_nil
        expect(recipe.has_tray).to be(false)
      end
    end

    context "tray_size d'un autre user" do
      let!(:other_tray) { create(:tray_size, name: 'Barquette 1kg', user: other_user) }

      it 'redirige vers root_path' do
        expect { delete tray_size_path(other_tray) }
          .not_to change(TraySize, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
