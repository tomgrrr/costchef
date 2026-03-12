require "rails_helper"

RSpec.describe "Health check", type: :request do
  describe "GET /health" do
    it "returns 200 and status ok when database is available" do
      get "/health"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body["status"]).to eq("ok")
      expect(body["time"]).to be_present
    end
  end
end
