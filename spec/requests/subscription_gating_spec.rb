# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Subscription Gating', type: :request do
  describe 'gating for unsubscribed users' do
    let(:unsubscribed_user) { create(:user, subscription_active: false) }

    before { sign_in unsubscribed_user }

    it 'redirects to /subscription_required for protected routes' do
      get root_path
      expect(response).to redirect_to(subscription_required_path)
    end

    it 'shows alert message about inactive subscription' do
      get root_path
      follow_redirect!
      expect(response.body).to include('abonnement')
    end

    it 'allows access to /subscription_required page' do
      get subscription_required_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'access for subscribed users' do
    let(:subscribed_user) { create(:user, :subscribed) }

    before { sign_in subscribed_user }

    it 'allows access to protected routes' do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it 'redirects away from /subscription_required' do
      get subscription_required_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'Devise controllers exemption' do
    let(:unsubscribed_user) { create(:user, subscription_active: false) }

    it 'allows access to login page without subscription' do
      get new_user_session_path
      expect(response).to have_http_status(:ok)
    end

    it 'allows logout without subscription' do
      sign_in unsubscribed_user
      delete destroy_user_session_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'allows access to password reset page without subscription' do
      get new_user_password_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'admin exemption from subscription gating' do
    let(:admin_without_subscription) { create(:user, :admin, subscription_active: false) }

    before { sign_in admin_without_subscription }

    it 'allows admin access to /admin even without subscription' do
      get admin_users_path
      expect(response).to have_http_status(:ok)
    end

    it 'allows admin access to /admin/invitations even without subscription' do
      get admin_invitations_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'unauthenticated users' do
    it 'redirects to login page instead of subscription_required' do
      get root_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
