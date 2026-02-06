# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Recipes Security', type: :request do
  let(:user_a) { create(:user, :subscribed) }
  let(:user_b) { create(:user, :subscribed) }
  let!(:recipe_a) { create(:recipe, user: user_a, name: 'Verrine saumon-avocat') }
  let!(:recipe_b) { create(:recipe, user: user_b, name: 'Salade César') }

  before { sign_in user_b }

  describe 'GET /recipes (index)' do
    it 'does not show recipes from other users' do
      get recipes_path
      expect(response.body).not_to include('Verrine saumon-avocat')
    end

    it 'shows only the current user recipes' do
      get recipes_path
      expect(response.body).to include('Salade César')
    end
  end

  describe 'GET /recipes/:id (show)' do
    it "raises RecordNotFound when accessing another user's recipe" do
      expect {
        get recipe_path(recipe_a)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'allows access to own recipe' do
      get recipe_path(recipe_b)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /recipes/:id/edit (edit)' do
    it "raises RecordNotFound when trying to edit another user's recipe" do
      expect {
        get edit_recipe_path(recipe_a)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'allows editing own recipe' do
      get edit_recipe_path(recipe_b)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /recipes/:id (update)' do
    it "raises RecordNotFound when trying to update another user's recipe" do
      expect {
        patch recipe_path(recipe_a), params: { recipe: { name: 'Recette modifiée' } }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'allows updating own recipe' do
      patch recipe_path(recipe_b), params: { recipe: { name: 'Nouvelle Salade César' } }
      expect(response).to redirect_to(recipe_path(recipe_b))
      expect(recipe_b.reload.name).to eq('Nouvelle Salade César')
    end
  end

  describe 'DELETE /recipes/:id (destroy)' do
    it "raises RecordNotFound when trying to delete another user's recipe" do
      expect {
        delete recipe_path(recipe_a)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'allows deleting own recipe' do
      expect {
        delete recipe_path(recipe_b)
      }.to change(Recipe, :count).by(-1)
    end
  end

  describe 'recipe_ingredients isolation' do
    let!(:product_a) { create(:product, user: user_a, name: 'Saumon', price: 45.00) }
    let!(:product_b) { create(:product, user: user_b, name: 'Poulet', price: 12.00) }

    context 'when trying to add ingredients to another user recipe' do
      it "raises RecordNotFound when POST to another user's recipe ingredients" do
        expect {
          post recipe_recipe_ingredients_path(recipe_a),
               params: { recipe_ingredient: { product_id: product_a.id, quantity: 0.5 } }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when trying to use another user product in own recipe' do
      it 'prevents adding another user product to own recipe' do
        # User B tries to use User A's product in their own recipe
        # This should either raise RecordNotFound or reject the product
        expect {
          post recipe_recipe_ingredients_path(recipe_b),
               params: { recipe_ingredient: { product_id: product_a.id, quantity: 0.5 } }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'cross-user data isolation' do
    it 'User B cannot see count of User A recipes' do
      get recipes_path
      # User B should only see their own recipe count
      expect(assigns(:recipes).count).to eq(1)
    end

    it 'prevents accessing recipe by guessing ID' do
      # Even knowing the exact ID, User B cannot access User A's recipe
      expect {
        get recipe_path(id: recipe_a.id)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'duplicate recipe isolation' do
    it "raises RecordNotFound when trying to duplicate another user's recipe" do
      expect {
        post duplicate_recipe_path(recipe_a)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
