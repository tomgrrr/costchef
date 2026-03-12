require "rails_helper"

RSpec.describe "Rack::Attack", type: :request do
  before do
    Rack::Attack.enabled = true
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  after do
    Rack::Attack.reset!
  end

  describe "POST /users/sign_in throttling by IP" do
    it "allows up to 5 requests" do
      5.times do
        post user_session_path, params: { user: { email: "test@example.com", password: "wrong" } }
        expect(response.status).not_to eq(429)
      end
    end

    it "blocks the 6th request from the same IP" do
      6.times do
        post user_session_path, params: { user: { email: "test@example.com", password: "wrong" } }
      end

      expect(response.status).to eq(429)
      expect(response.body).to include("Trop de tentatives")
    end
  end

  describe "POST /users/sign_in throttling by email" do
    it "blocks after 5 attempts with the same email" do
      6.times do |i|
        post user_session_path,
             params: { user: { email: "victim@example.com", password: "wrong" } },
             headers: { "REMOTE_ADDR" => "1.2.3.#{i}" }
      end

      expect(response.status).to eq(429)
    end
  end

  describe "non-login requests" do
    let(:user) { create(:user) }

    it "does not throttle other endpoints" do
      sign_in user
      10.times { get root_path }

      expect(response.status).not_to eq(429)
    end
  end
end
