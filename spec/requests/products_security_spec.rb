# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Products Security', type: :request do
  let(:user_a) { create(:user, :subscribed) }
  let(:user_b) { create(:user, :subscribed) }
  let!(:product_a) { create(:product, user: user_a, name: 'Saumon fumé', price: 45.00) }
  let!(:product_b) { create(:product, user: user_b, name: 'Avocat', price: 8.50) }

  before { sign_in user_b }

  describe 'GET /products (index)' do
    it 'does not show products from other users' do
      get products_path
      expect(response.body).not_to include('Saumon fumé')
    end

    it 'shows only the current user products' do
      get products_path
      expect(response.body).to include('Avocat')
    end
  end

  describe 'GET /products/:id (show)' do
    it "raises RecordNotFound when accessing another user's product" do
      expect {
        get product_path(product_a)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'allows access to own product' do
      get product_path(product_b)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /products/:id/edit (edit)' do
    it "raises RecordNotFound when trying to edit another user's product" do
      expect {
        get edit_product_path(product_a)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'allows editing own product' do
      get edit_product_path(product_b)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /products/:id (update)' do
    it "raises RecordNotFound when trying to update another user's product" do
      expect {
        patch product_path(product_a), params: { product: { price: 50.00 } }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'allows updating own product' do
      patch product_path(product_b), params: { product: { price: 10.00 } }
      expect(response).to redirect_to(product_path(product_b))
      expect(product_b.reload.price).to eq(10.00)
    end
  end

  describe 'DELETE /products/:id (destroy)' do
    it "raises RecordNotFound when trying to delete another user's product" do
      expect {
        delete product_path(product_a)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'allows deleting own product' do
      expect {
        delete product_path(product_b)
      }.to change(Product, :count).by(-1)
    end
  end

  describe 'cross-user data isolation' do
    it 'User B cannot see count of User A products' do
      get products_path
      # User B should only see their own product (1 product)
      expect(response.body).to include('1 produit')
      expect(response.body).not_to include('2 produits')
    end

    it 'prevents accessing product by guessing ID' do
      # Even knowing the exact ID, User B cannot access User A's product
      expect {
        get product_path(id: product_a.id)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
