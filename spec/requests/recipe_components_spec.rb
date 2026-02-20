# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RecipeComponents', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user, email: 'other@test.fr') }
  let(:product) { create(:product, user: user, avg_price_per_kg: 4.0) }
  let(:recipe) { create(:recipe, user: user) }
  let(:turbo_headers) { { 'Accept' => 'text/vnd.turbo-stream.html' } }

  before do
    sign_in user
    allow(Recalculations::Dispatcher).to receive(:recipe_component_changed)
  end

  describe 'POST /recipes/:recipe_id/recipe_components' do
    let(:valid_params) do
      {
        recipe_component: {
          component_type: 'Product',
          component_id: product.id,
          quantity_unit: 'kg',
          quantity: '0.5'
        }
      }
    end

    context 'données valides — composant Product en kg' do
      it 'crée le recipe_component' do
        expect { post recipe_recipe_components_path(recipe), params: valid_params, headers: turbo_headers }
          .to change(RecipeComponent, :count).by(1)
      end

      it 'quantity_kg est bien calculé via Units::Converter (0.5 kg → 0.5)' do
        post recipe_recipe_components_path(recipe), params: valid_params, headers: turbo_headers
        expect(RecipeComponent.last.quantity_kg).to eq(0.5)
      end

      it 'appelle Dispatcher.recipe_component_changed avec la recette' do
        post recipe_recipe_components_path(recipe), params: valid_params, headers: turbo_headers
        expect(Recalculations::Dispatcher).to have_received(:recipe_component_changed).with(recipe)
      end

      it 'retourne une réponse turbo_stream HTTP 200' do
        post recipe_recipe_components_path(recipe), params: valid_params, headers: turbo_headers
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('turbo-stream')
      end

      it 'la réponse contient les ids components_ et summary_' do
        post recipe_recipe_components_path(recipe), params: valid_params, headers: turbo_headers
        expect(response.body).to include("components_#{recipe.id}")
        expect(response.body).to include("summary_#{recipe.id}")
      end
    end

    context 'données valides — composant Product en grammes' do
      it 'quantity_kg vaut 0.5 après conversion (500g → 0.5kg)' do
        params = { recipe_component: { component_type: 'Product', component_id: product.id, quantity_unit: 'g', quantity: '500' } }
        post recipe_recipe_components_path(recipe), params: params, headers: turbo_headers
        expect(RecipeComponent.last.quantity_kg).to eq(0.5)
      end
    end

    context 'données valides — composant Recipe (sous-recette)' do
      let(:subrecipe) { create(:recipe, :subrecipe, name: 'Crème pâtissière', user: user, cached_cost_per_kg: 8.0) }

      it 'crée le recipe_component' do
        params = { recipe_component: { component_type: 'Recipe', component_id: subrecipe.id, quantity_unit: 'kg', quantity: '1' } }
        expect { post recipe_recipe_components_path(recipe), params: params, headers: turbo_headers }
          .to change(RecipeComponent, :count).by(1)
      end

      it 'appelle Dispatcher' do
        params = { recipe_component: { component_type: 'Recipe', component_id: subrecipe.id, quantity_unit: 'kg', quantity: '1' } }
        post recipe_recipe_components_path(recipe), params: params, headers: turbo_headers
        expect(Recalculations::Dispatcher).to have_received(:recipe_component_changed).with(recipe)
      end
    end

    context 'données invalides — quantity manquante ou 0' do
      it 'ne crée pas le recipe_component' do
        params = { recipe_component: { component_type: 'Product', component_id: product.id, quantity_unit: 'kg', quantity: '0' } }
        expect { post recipe_recipe_components_path(recipe), params: params, headers: turbo_headers }
          .not_to change(RecipeComponent, :count)
      end

      it 'retourne turbo_stream HTTP 200 avec le formulaire en erreur' do
        params = { recipe_component: { component_type: 'Product', component_id: product.id, quantity_unit: 'kg', quantity: '0' } }
        post recipe_recipe_components_path(recipe), params: params, headers: turbo_headers
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('turbo-stream')
      end

      it 'ne appelle pas Dispatcher' do
        params = { recipe_component: { component_type: 'Product', component_id: product.id, quantity_unit: 'kg', quantity: '0' } }
        post recipe_recipe_components_path(recipe), params: params, headers: turbo_headers
        expect(Recalculations::Dispatcher).not_to have_received(:recipe_component_changed)
      end
    end

    context 'isolation — product appartenant à other_user' do
      let(:other_product) { create(:product, name: 'Beurre', user: other_user) }

      it 'redirige vers root_path (RecordNotFound)' do
        params = { recipe_component: { component_type: 'Product', component_id: other_product.id, quantity_unit: 'kg', quantity: '0.5' } }
        post recipe_recipe_components_path(recipe), params: params, headers: turbo_headers
        expect(response).to redirect_to(root_path)
      end

      it 'ne crée pas le recipe_component' do
        params = { recipe_component: { component_type: 'Product', component_id: other_product.id, quantity_unit: 'kg', quantity: '0.5' } }
        expect { post recipe_recipe_components_path(recipe), params: params, headers: turbo_headers }
          .not_to change(RecipeComponent, :count)
      end
    end

    context 'isolation — recipe appartenant à other_user' do
      let(:other_recipe) { create(:recipe, name: 'Autre recette', user: other_user) }

      it 'redirige vers root_path (RecordNotFound)' do
        params = { recipe_component: { component_type: 'Product', component_id: product.id, quantity_unit: 'kg', quantity: '0.5' } }
        post recipe_recipe_components_path(other_recipe), params: params, headers: turbo_headers
        expect(response).to redirect_to(root_path)
      end
    end

    context 'isolation — sous-recette appartenant à other_user' do
      let(:other_subrecipe) { create(:recipe, :subrecipe, name: 'Crème other', user: other_user) }

      it 'ne crée pas le recipe_component (validate_same_user)' do
        params = { recipe_component: { component_type: 'Recipe', component_id: other_subrecipe.id, quantity_unit: 'kg', quantity: '1' } }
        expect { post recipe_recipe_components_path(recipe), params: params, headers: turbo_headers }
          .not_to change(RecipeComponent, :count)
      end

      it 'retourne turbo_stream HTTP 200 avec erreur de validation' do
        params = { recipe_component: { component_type: 'Recipe', component_id: other_subrecipe.id, quantity_unit: 'kg', quantity: '1' } }
        post recipe_recipe_components_path(recipe), params: params, headers: turbo_headers
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('turbo-stream')
      end
    end
  end

  describe 'PATCH /recipes/:recipe_id/recipe_components/:id' do
    let!(:component) do
      create(:recipe_component,
             parent_recipe: recipe,
             component: product,
             quantity_kg: 0.5,
             quantity_unit: 'kg')
    end

    context 'données valides' do
      it 'met à jour quantity_kg via conversion' do
        params = { recipe_component: { component_type: 'Product', component_id: product.id, quantity_unit: 'kg', quantity: '1.0' } }
        patch recipe_recipe_component_path(recipe, component), params: params, headers: turbo_headers
        expect(component.reload.quantity_kg).to eq(1.0)
      end

      it 'appelle Dispatcher.recipe_component_changed' do
        params = { recipe_component: { component_type: 'Product', component_id: product.id, quantity_unit: 'kg', quantity: '1.0' } }
        patch recipe_recipe_component_path(recipe, component), params: params, headers: turbo_headers
        expect(Recalculations::Dispatcher).to have_received(:recipe_component_changed).with(recipe)
      end

      it 'retourne turbo_stream HTTP 200' do
        params = { recipe_component: { component_type: 'Product', component_id: product.id, quantity_unit: 'kg', quantity: '1.0' } }
        patch recipe_recipe_component_path(recipe, component), params: params, headers: turbo_headers
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('turbo-stream')
      end
    end

    context 'données invalides' do
      it 'ne met pas à jour' do
        params = { recipe_component: { component_type: 'Product', component_id: product.id, quantity_unit: 'kg', quantity: '0' } }
        patch recipe_recipe_component_path(recipe, component), params: params, headers: turbo_headers
        expect(component.reload.quantity_kg).to eq(0.5)
      end

      it 'retourne turbo_stream HTTP 200 avec formulaire en erreur' do
        params = { recipe_component: { component_type: 'Product', component_id: product.id, quantity_unit: 'kg', quantity: '0' } }
        patch recipe_recipe_component_path(recipe, component), params: params, headers: turbo_headers
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('turbo-stream')
      end

      it 'ne appelle pas Dispatcher' do
        params = { recipe_component: { component_type: 'Product', component_id: product.id, quantity_unit: 'kg', quantity: '0' } }
        patch recipe_recipe_component_path(recipe, component), params: params, headers: turbo_headers
        expect(Recalculations::Dispatcher).not_to have_received(:recipe_component_changed)
      end
    end

    context "composant d'un autre user" do
      let(:other_recipe) { create(:recipe, name: 'Autre recette', user: other_user) }
      let(:other_product) { create(:product, name: 'Beurre', user: other_user) }
      let!(:other_component) do
        create(:recipe_component, parent_recipe: other_recipe, component: other_product)
      end

      it 'redirige vers root_path' do
        params = { recipe_component: { component_type: 'Product', component_id: other_product.id, quantity_unit: 'kg', quantity: '1' } }
        patch recipe_recipe_component_path(other_recipe, other_component), params: params, headers: turbo_headers
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'DELETE /recipes/:recipe_id/recipe_components/:id' do
    let!(:component) do
      create(:recipe_component,
             parent_recipe: recipe,
             component: product,
             quantity_kg: 0.5,
             quantity_unit: 'kg')
    end

    context 'composant du user connecté' do
      it 'supprime le recipe_component' do
        expect { delete recipe_recipe_component_path(recipe, component), headers: turbo_headers }
          .to change(RecipeComponent, :count).by(-1)
      end

      it 'appelle Dispatcher.recipe_component_changed avec la recette' do
        delete recipe_recipe_component_path(recipe, component), headers: turbo_headers
        expect(Recalculations::Dispatcher).to have_received(:recipe_component_changed).with(recipe)
      end

      it 'retourne turbo_stream HTTP 200' do
        delete recipe_recipe_component_path(recipe, component), headers: turbo_headers
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('turbo-stream')
      end

      it 'la réponse contient les ids components_ et summary_' do
        delete recipe_recipe_component_path(recipe, component), headers: turbo_headers
        expect(response.body).to include("components_#{recipe.id}")
        expect(response.body).to include("summary_#{recipe.id}")
      end
    end

    context "composant d'un autre user" do
      let(:other_recipe) { create(:recipe, name: 'Autre recette', user: other_user) }
      let(:other_product) { create(:product, name: 'Beurre', user: other_user) }
      let!(:other_component) do
        create(:recipe_component, parent_recipe: other_recipe, component: other_product)
      end

      it 'redirige vers root_path sans supprimer' do
        expect { delete recipe_recipe_component_path(other_recipe, other_component), headers: turbo_headers }
          .not_to change(RecipeComponent, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
