require "rails_helper"

describe Sites::Admin::ActivityRecordsController do
  let(:user) { FactoryBot.create(:user, is_admin: true) }
  let(:locale) { FactoryBot.create(:locale) }
  let(:site) { FactoryBot.create(:site, locales: [locale]) }
  let(:record) { FactoryBot.create(:activity_record, user_id: user.id, site_id: site.id) }

  before do
    @request.host = "#{site.name}.example.com"
    sign_in user
  end

  context "GET #index" do
    #before { get :index }

    skip "assigns @activity_records" do
      get :index
      expect(assigns(:activity_records)).to eq([record])
    end

    skip "renders the :index view" do
      get :index
      expect(response).to render_template(:index)
    end
  end

  context "GET #show" do
    before { get :show, :id => record.id }

    it "assigns @activity_record" do
      expect(assigns(:activity_record)).to eq(record)
    end

    it "renders the :show view" do
      expect(response).to render_template(:show)
    end
  end
end
