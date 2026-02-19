# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Products', type: :request do
  let(:user) { create(:user, email: 'chef@test.fr') }
  let(:other_user) { create(:user, email: 'other@test.fr') }

  describe 'GET /products' do
    context 'non connecté' do
      it 'redirige vers login' do
        get products_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'connecté sans abonnement' do
      let(:user) { create(:user, email: 'chef@test.fr', subscription_active: false) }

      before { sign_in user }

      it 'redirige vers subscription_required' do
        get products_path
        expect(response).to redirect_to(subscription_required_path)
      end
    end

    context 'connecté avec abonnement' do
      before { sign_in user }

      it 'retourne HTTP 200' do
        get products_path
        expect(response).to have_http_status(:ok)
      end

      it 'affiche les produits du user connecté' do
        product = create(:product, name: 'Farine T55', user: user)
        get products_path
        expect(response.body).to include(product.name)
      end

      it "n'affiche pas les produits d'un autre user" do
        other_product = create(:product, name: 'Beurre doux', user: other_user)
        get products_path
        expect(response.body).not_to include(other_product.name)
      end

      it 'filtre par nom avec params[:search]' do
        create(:product, name: 'Farine T55', user: user)
        create(:product, name: 'Beurre doux', user: user)
        get products_path, params: { search: 'farine' }
        expect(response.body).to include('Farine T55')
        expect(response.body).not_to include('Beurre doux')
      end

      it 'affiche un message quand la recherche ne retourne rien' do
        get products_path, params: { search: 'inexistant' }
        expect(response.body).to include('Aucun produit trouvé')
      end
    end
  end

  describe 'POST /products' do
    before { sign_in user }

    context 'base_unit kg, nom valide' do
      it 'crée le produit et redirige avec notice' do
        expect { post products_path, params: { product: { name: 'Farine T55', base_unit: 'kg' } } }
          .to change(user.products, :count).by(1)
        expect(response).to redirect_to(products_path)
        follow_redirect!
        expect(response.body).to include('Produit créé')
      end
    end

    context 'base_unit l, nom valide' do
      it 'crée le produit' do
        expect { post products_path, params: { product: { name: 'Lait entier', base_unit: 'l' } } }
          .to change(user.products, :count).by(1)
      end
    end

    context 'base_unit piece avec unit_weight_kg' do
      it 'crée le produit' do
        expect {
          post products_path, params: { product: { name: 'Oeuf', base_unit: 'piece', unit_weight_kg: 0.060 } }
        }.to change(user.products, :count).by(1)
      end
    end

    context 'base_unit piece sans unit_weight_kg' do
      it 'ne crée pas et retourne HTTP 422' do
        expect {
          post products_path, params: { product: { name: 'Oeuf', base_unit: 'piece' } }
        }.not_to change(Product, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'nom vide' do
      it 'ne crée pas et retourne HTTP 422' do
        expect { post products_path, params: { product: { name: '', base_unit: 'kg' } } }
          .not_to change(Product, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'nom déjà pris par le même user' do
      before { create(:product, name: 'Farine T55', user: user) }

      it 'ne crée pas et retourne HTTP 422' do
        expect { post products_path, params: { product: { name: 'Farine T55', base_unit: 'kg' } } }
          .not_to change(Product, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "nom déjà pris par un autre user" do
      before { create(:product, name: 'Farine T55', user: other_user) }

      it 'crée le produit (unicité scoped user_id)' do
        expect { post products_path, params: { product: { name: 'Farine T55', base_unit: 'kg' } } }
          .to change(user.products, :count).by(1)
      end
    end
  end

  describe 'PATCH /products/:id' do
    before { sign_in user }

    let!(:product) { create(:product, name: 'Farine T55', base_unit: 'kg', user: user) }

    context 'attributs valides' do
      it 'met à jour et redirige avec notice' do
        patch product_path(product), params: { product: { name: 'Farine T65' } }
        expect(product.reload.name).to eq('Farine T65')
        expect(response).to redirect_to(products_path)
        follow_redirect!
        expect(response.body).to include('Produit mis à jour')
      end
    end

    context 'passage de kg à piece sans unit_weight_kg' do
      it 'retourne HTTP 422' do
        patch product_path(product), params: { product: { base_unit: 'piece' } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(product.reload.base_unit).to eq('kg')
      end
    end

    context 'passage de piece à kg' do
      let!(:product) { create(:product, :piece, name: 'Oeuf', user: user) }

      it 'met unit_weight_kg à nil et update OK' do
        patch product_path(product), params: { product: { base_unit: 'kg', unit_weight_kg: nil } }
        expect(product.reload.base_unit).to eq('kg')
        expect(product.unit_weight_kg).to be_nil
      end
    end

    context "produit d'un autre user" do
      let!(:other_product) { create(:product, name: 'Beurre', user: other_user) }

      it 'redirige vers root_path' do
        patch product_path(other_product), params: { product: { name: 'Hack' } }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'DELETE /products/:id' do
    before { sign_in user }

    context 'produit sans recette' do
      let!(:product) { create(:product, name: 'Farine T55', user: user) }

      it 'supprime et redirige avec notice' do
        expect { delete product_path(product) }
          .to change(Product, :count).by(-1)
        expect(response).to redirect_to(products_path)
        follow_redirect!
        expect(response.body).to include('Produit supprimé')
      end
    end

    context 'produit utilisé dans une recette' do
      let!(:product) { create(:product, name: 'Farine T55', user: user) }
      let!(:recipe) { create(:recipe, name: 'Pâte brisée', user: user) }
      let!(:component) do
        create(:recipe_component, parent_recipe: recipe, component: product)
      end

      it 'ne supprime pas et redirige avec alert contenant recette' do
        expect { delete product_path(product) }
          .not_to change(Product, :count)
        expect(response).to redirect_to(products_path)
        follow_redirect!
        expect(response.body).to include('recette')
      end
    end

    context "produit d'un autre user" do
      let!(:other_product) { create(:product, name: 'Beurre', user: other_user) }

      it 'redirige vers root_path' do
        delete product_path(other_product)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
