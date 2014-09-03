require "rails_helper"

describe Sites::Admin::BackupsController do
  let(:user) { FactoryGirl.create(:user, is_admin: true) }
  let(:locale) { FactoryGirl.create(:locale) }
  let(:site) { FactoryGirl.create(:site, locales: [locale]) }

  before { sign_in user }

  describe "GET #index" do
    before { get :index }

    it "renders the :index view" do
      expect(response.headers['Content-Type']).to eq("text/html; charset=utf-8")
    end
  end

  skip "generate" do
  end

  skip "import" do
  end
end
