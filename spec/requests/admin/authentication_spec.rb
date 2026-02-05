# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Authentication', type: :request do
  describe 'non-admin user access' do
    let(:regular_user) { create(:user, :subscribed, admin: false) }

    before { sign_in regular_user }

    it 'denies access to admin users list' do
      get admin_users_path
      expect(response).to redirect_to(root_path)
    end

    it 'denies access to admin invitations list' do
      get admin_invitations_path
      expect(response).to redirect_to(root_path)
    end

    it 'denies access to new invitation form' do
      get new_admin_invitation_path
      expect(response).to redirect_to(root_path)
    end

    it 'sets admin-only alert flash message' do
      get admin_users_path
      expect(flash[:alert]).to include('administrateur')
    end
  end

  describe 'admin user access' do
    let(:admin_user) { create(:user, :admin, :subscribed) }

    before { sign_in admin_user }

    it 'allows access to admin users list' do
      get admin_users_path
      expect(response).to have_http_status(:ok)
    end

    it 'allows access to admin invitations list' do
      get admin_invitations_path
      expect(response).to have_http_status(:ok)
    end

    it 'allows access to new invitation form' do
      get new_admin_invitation_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'admin access without subscription' do
    let(:admin_without_subscription) { create(:user, :admin, subscription_active: false) }

    before { sign_in admin_without_subscription }

    it 'allows admin access to /admin/users without subscription' do
      get admin_users_path
      expect(response).to have_http_status(:ok)
    end

    it 'allows admin access to /admin/invitations without subscription' do
      get admin_invitations_path
      expect(response).to have_http_status(:ok)
    end

    it 'allows admin to create invitations without subscription' do
      get new_admin_invitation_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'unauthenticated access' do
    it 'redirects to login for admin users list' do
      get admin_users_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects to login for admin invitations' do
      get admin_invitations_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
