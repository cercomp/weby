require "rails_helper"

describe Sites::Admin::ComponentsController do
  let(:user) { FactoryGirl.create(:user, is_admin: true) }
  let(:locale) { FactoryGirl.create(:locale) }
  let(:site) { FactoryGirl.create(:site, locales: [locale]) }
  let(:first_component) { FactoryGirl.create(:component, site_id: site.id) }

  before { sign_in user }

  describe "GET #index" do
    before { get :index }

    skip "assigns @components" do
      expect(assigns(:components)).to eq([first_component])
    end

    skip "will render :index view" do
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    before { get :show, :id => first_component.id }

    skip "will redirect to site_admin_skins_path" do
      expet(response).to redirect_to site_admin_skins_path
    end
  end

  describe "GET #new" do
    before { get :new }

    it "renders a custom view" do
      expect(response).to render_template(:available_components)
    end
  end

  describe "GET #show" do
    before { get :show, :id => first_component.id }

    skip "assigns @component" do
      expect(assigns(:component)).to eq(first_component)
    end
  end

  describe "POST #create" do
    context "when valid" do
      before { post :create, :post => { :site_id => site.id, :name => "Site" } }

      skip "will redirect to spendinge_admin_components_path" do
        expect(response).to redirect_to(site_admin_skins_path)
      end
    end

    context "when invalid" do
      before { post :create, :post => { :site_id => site.id, :name => "" } }

      skip "will render thew :new view" do
        expect(response).to render_template(:new)
      end
    end
  end

  describe "PUT #update" do
   # before { update_params }

    context "when valid" do
      before { put :update, :post => { :name => "Site2" }, :id => first_component.id }

      skip "will redirect to spendinge_admin_components_path" do
        expect(response).to redirect_to(site_admin_skins_path)
      end
    end

    context "when invalid" do
      before { put :update, :post => { :name => "" }, :id => first_component.id }

      skip "will render :edpending view" do
        expect(response).to render_template(:show)
      end
    end
  end

  describe "DELETE #destroy" do
    before { delete :destroy, :id => first_component.id }

    skip "will redirect to spendinge_admin_components_path" do
      expect(response).to redirect_to(site_admin_skins_path)
    end

    skip "will flash[:success]" do
      expect(flash[:success]).to be_present
    end
  end
end
