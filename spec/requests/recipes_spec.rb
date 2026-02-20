# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Recipes', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user, email: 'other@test.fr') }

  describe 'GET /recipes' do
    context 'non connecté' do
      it 'redirige vers login' do
        get recipes_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'connecté sans abonnement' do
      let(:user) { create(:user, subscription_active: false) }

      before { sign_in user }

      it 'redirige vers subscription_required' do
        get recipes_path
        expect(response).to redirect_to(subscription_required_path)
      end
    end

    context 'connecté avec abonnement' do
      before { sign_in user }

      it 'retourne HTTP 200' do
        get recipes_path
        expect(response).to have_http_status(:ok)
      end

      it 'affiche les recettes du user connecté' do
        recipe = create(:recipe, name: 'Pâte brisée', user: user)
        get recipes_path
        expect(response.body).to include(recipe.name)
      end

      it "n'affiche pas les recettes d'un autre user" do
        other_recipe = create(:recipe, name: 'Crème brûlée', user: other_user)
        get recipes_path
        expect(response.body).not_to include(other_recipe.name)
      end

      it 'filtre par nom avec params[:search]' do
        create(:recipe, name: 'Pâte brisée', user: user)
        create(:recipe, name: 'Crème brûlée', user: user)
        get recipes_path, params: { search: 'pâte' }
        expect(response.body).to include('Pâte brisée')
        expect(response.body).not_to include('Crème brûlée')
      end

      it 'affiche message vide si recherche sans résultat' do
        get recipes_path, params: { search: 'inexistant' }
        expect(response.body).to include('Aucune recette')
      end
    end
  end

  describe 'GET /recipes/:id' do
    before { sign_in user }

    it 'retourne HTTP 200 pour une recette du user' do
      recipe = create(:recipe, name: 'Pâte brisée', user: user)
      get recipe_path(recipe)
      expect(response).to have_http_status(:ok)
    end

    it 'affiche le nom de la recette' do
      recipe = create(:recipe, name: 'Pâte brisée', user: user)
      get recipe_path(recipe)
      expect(response.body).to include('Pâte brisée')
    end

    it "redirige vers root_path pour une recette d'un autre user" do
      other_recipe = create(:recipe, name: 'Crème brûlée', user: other_user)
      get recipe_path(other_recipe)
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET /recipes/new' do
    before { sign_in user }

    it 'retourne HTTP 200' do
      get new_recipe_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /recipes' do
    before do
      sign_in user
      allow(Recalculations::Dispatcher).to receive(:recipe_changed)
    end

    context 'données valides' do
      it 'crée la recette' do
        expect { post recipes_path, params: { recipe: { name: 'Pâte brisée' } } }
          .to change(user.recipes, :count).by(1)
      end

      it 'appelle Recalculations::Dispatcher.recipe_changed' do
        post recipes_path, params: { recipe: { name: 'Pâte brisée' } }
        expect(Recalculations::Dispatcher).to have_received(:recipe_changed)
      end

      it 'redirige vers la recette créée avec notice' do
        post recipes_path, params: { recipe: { name: 'Pâte brisée' } }
        expect(response).to redirect_to(Recipe.last)
        follow_redirect!
        expect(response.body).to include('Recette créée')
      end
    end

    context 'nom vide' do
      it 'ne crée pas' do
        expect { post recipes_path, params: { recipe: { name: '' } } }
          .not_to change(Recipe, :count)
      end

      it 'retourne HTTP 422' do
        post recipes_path, params: { recipe: { name: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'nom déjà pris par le même user' do
      before { create(:recipe, name: 'Pâte brisée', user: user) }

      it 'ne crée pas' do
        expect { post recipes_path, params: { recipe: { name: 'Pâte brisée' } } }
          .not_to change(Recipe, :count)
      end

      it 'retourne HTTP 422' do
        post recipes_path, params: { recipe: { name: 'Pâte brisée' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "nom déjà pris par un autre user" do
      before { create(:recipe, name: 'Pâte brisée', user: other_user) }

      it 'crée la recette (unicité scoped user_id)' do
        expect { post recipes_path, params: { recipe: { name: 'Pâte brisée' } } }
          .to change(user.recipes, :count).by(1)
      end
    end
  end

  describe 'GET /recipes/:id/edit' do
    before { sign_in user }

    it 'retourne HTTP 200 pour une recette du user' do
      recipe = create(:recipe, name: 'Pâte brisée', user: user)
      get edit_recipe_path(recipe)
      expect(response).to have_http_status(:ok)
    end

    it "redirige vers root_path pour une recette d'un autre user" do
      other_recipe = create(:recipe, name: 'Crème brûlée', user: other_user)
      get edit_recipe_path(other_recipe)
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'PATCH /recipes/:id' do
    before do
      sign_in user
      allow(Recalculations::Dispatcher).to receive(:recipe_changed)
    end

    let!(:recipe) { create(:recipe, name: 'Pâte brisée', cooking_loss_percentage: 10, user: user) }

    context 'données valides (format HTML)' do
      it 'met à jour le nom' do
        patch recipe_path(recipe), params: { recipe: { name: 'Pâte sablée' } }
        expect(recipe.reload.name).to eq('Pâte sablée')
      end

      it 'redirige vers la recette avec notice' do
        patch recipe_path(recipe), params: { recipe: { name: 'Pâte sablée' } }
        expect(response).to redirect_to(recipe)
        follow_redirect!
        expect(response.body).to include('Recette mise à jour')
      end
    end

    context 'cooking_loss_percentage modifié' do
      it 'appelle Dispatcher.recipe_changed' do
        patch recipe_path(recipe), params: { recipe: { cooking_loss_percentage: 20 } }
        expect(Recalculations::Dispatcher).to have_received(:recipe_changed).with(recipe)
      end
    end

    context 'cooking_loss_percentage non modifié' do
      it 'ne appelle pas Dispatcher.recipe_changed' do
        patch recipe_path(recipe), params: { recipe: { name: 'Pâte sablée' } }
        expect(Recalculations::Dispatcher).not_to have_received(:recipe_changed)
      end
    end

    context 'données invalides' do
      it 'retourne HTTP 422' do
        patch recipe_path(recipe), params: { recipe: { name: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "recette d'un autre user" do
      let!(:other_recipe) { create(:recipe, name: 'Crème brûlée', user: other_user) }

      it 'redirige vers root_path' do
        patch recipe_path(other_recipe), params: { recipe: { name: 'Hack' } }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'DELETE /recipes/:id' do
    before { sign_in user }

    context 'recette non utilisée comme sous-recette' do
      let!(:recipe) { create(:recipe, name: 'Pâte brisée', user: user) }

      it 'supprime la recette' do
        expect { delete recipe_path(recipe) }
          .to change(Recipe, :count).by(-1)
      end

      it 'redirige vers recipes_path avec notice' do
        delete recipe_path(recipe)
        expect(response).to redirect_to(recipes_path)
        follow_redirect!
        expect(response.body).to include('Recette supprimée')
      end
    end

    context 'recette utilisée comme sous-recette' do
      let!(:subrecipe) { create(:recipe, :subrecipe, name: 'Crème pâtissière', user: user) }
      let!(:parent) { create(:recipe, name: 'Mille-feuille', user: user) }
      let!(:component) do
        create(:recipe_component, parent_recipe: parent, component: subrecipe)
      end

      it 'ne supprime pas' do
        expect { delete recipe_path(subrecipe) }
          .not_to change(Recipe, :count)
      end

      it 'redirige vers recipes_path avec alert contenant sous-recette' do
        delete recipe_path(subrecipe)
        expect(response).to redirect_to(recipes_path)
        follow_redirect!
        expect(response.body).to include('sous-recette')
      end
    end

    context "recette d'un autre user" do
      let!(:other_recipe) { create(:recipe, name: 'Crème brûlée', user: other_user) }

      it 'redirige vers root_path sans supprimer' do
        expect { delete recipe_path(other_recipe) }
          .not_to change(Recipe, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'POST /recipes/:id/duplicate' do
    before do
      sign_in user
      allow(Recalculations::Dispatcher).to receive(:recipe_changed)
    end

    let!(:recipe) { create(:recipe, name: 'Pâte brisée', user: user) }
    let!(:product) { create(:product, name: 'Farine T55', user: user) }
    let!(:component) do
      create(:recipe_component, parent_recipe: recipe, component: product, quantity_kg: 0.5)
    end

    it 'crée une nouvelle recette avec "(copie)" dans le nom' do
      expect { post duplicate_recipe_path(recipe) }
        .to change(Recipe, :count).by(1)
      expect(Recipe.last.name).to eq('Pâte brisée (copie)')
    end

    it 'copie les recipe_components de la recette originale' do
      expect { post duplicate_recipe_path(recipe) }
        .to change(RecipeComponent, :count).by(1)
      new_component = Recipe.last.recipe_components.first
      expect(new_component.component).to eq(product)
      expect(new_component.quantity_kg).to eq(0.5)
    end

    it 'appelle Dispatcher.recipe_changed sur la nouvelle recette' do
      post duplicate_recipe_path(recipe)
      expect(Recalculations::Dispatcher).to have_received(:recipe_changed).with(Recipe.last)
    end

    it 'redirige vers la nouvelle recette avec notice' do
      post duplicate_recipe_path(recipe)
      expect(response).to redirect_to(Recipe.last)
      follow_redirect!
      expect(response.body).to include('Recette dupliquée')
    end

    it 'ne modifie pas la recette originale' do
      post duplicate_recipe_path(recipe)
      expect(recipe.reload.name).to eq('Pâte brisée')
      expect(recipe.recipe_components.count).to eq(1)
    end

    it "redirige vers root_path pour une recette d'un autre user" do
      other_recipe = create(:recipe, name: 'Crème brûlée', user: other_user)
      post duplicate_recipe_path(other_recipe)
      expect(response).to redirect_to(root_path)
    end
  end
end
