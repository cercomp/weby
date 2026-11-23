require "rails_helper"

RSpec.describe "User Sessions", type: :request do
  let!(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe "DELETE /logout" do
    it "logs the user out and redirects to root" do
      delete "/logout"
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "respects back_url parameter" do
      delete "/logout", params: { back_url: "http://example.com/site_target" }
      expect(response).to have_http_status(:redirect)
      expect(response.location).to eq("http://example.com/site_target")
    end
  end

  describe "GET /logout" do
    it "logs the user out and redirects to root when accessed via GET" do
      get "/logout"
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "respects back_url parameter via GET" do
      get "/logout", params: { back_url: "http://example.com/site_target" }
      expect(response).to have_http_status(:redirect)
      expect(response.location).to eq("http://example.com/site_target")
    end
  end
end
