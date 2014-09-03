require "rails_helper"

describe Sites::Admin::ExtensionsController do
  let(:user) { FactoryGirl.create(:user, is_admin: true) }
  let(:locale) { FactoryGirl.create(:locale) }
  let(:site) { FactoryGirl.create(:site, locales: [locale]) }
  let(:extension) { FactoryGirl.create(:extension, site_id: site.id) }

  before { sign_in user }

  describe "GET #index" do
    before { get :index }

    skip "assigns @extensions" do
      expect(assigns(:extensions)).to eq([extension])
    end

    skip "will render :index view" do
      expect(response).to render_template(:index)
    end
  end

  describe "GET #new" do
    before { get :new }

    it "assigns @extension" do
      expect(assigns(:extension)).to be_a_new(Extension)
    end

    it "will render :new view" do
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "when valid" do
      before { post :create, post: { :name => "Name" } }

      skip "will add extensions to the site" do
        expect(site.extensions).to eq([extension])
      end

      skip "redirect to site_admin_extensions_path" do
        expect(response).to redirect_to(site_admin_extensions_path)
      end
    end

    context "when invalid" do
      before { post :create, post: { :name => "" } }

      skip "will render :new view" do
        expect(response).to render_template(:new)
      end
    end
  end

  describe "DELETE #destroy" do
    before { delete :destroy, :id => extension.id }

    skip "will remove extension from the site" do
      expect(site.extensions).to eq([])
    end

    skip "will redirect to site_admin_extensions_path" do
      expect(response).to redirect_to(site_admin_extensions_path)
    end
  end
end
