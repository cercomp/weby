require "spec_helper"

describe Sites::Admin::ComponentsController do
  let(:user) { FactoryGirl.create(:user, is_admin: true) }
  let(:locale) { FactoryGirl.create(:locale) }
  let(:site) { FactoryGirl.create(:site, locales: [locale]) }
  let(:first_component) { FactoryGirl.create(:component, site_id: site.id) }

  before { sign_in user }

  describe "GET #index" do
    before { get :index }

    pending "assigns @components" do
      expect(assigns(:components)).to eq([first_component])
    end

    pending "will render :index view" do
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    before { get :show, :id => first_component.id }

    pending "will redirect to site_admin_components_path" do
      expet(response).to redirect_to site_admin_components_path
    end
  end

  describe "GET #new" do
    before { get :new }

    it "renders a custom view" do
      expect(response).to render_template(:available_components)
    end
  end

  describe "GET #edit" do
    before { get :edit, :id => first_component.id }

    pending "assigns @component" do
      expect(assigns(:component)).to eq(first_component)
    end
  end

  describe "POST #create" do
    context "when valid" do
      before { post :create, :post => { :site_id => site.id, :name => "Site" } }

      pending "will redirect to spendinge_admin_components_path" do
        expect(response).to redirect_to(site_admin_components_path)
      end
    end

    context "when invalid" do
      before { post :create, :post => { :site_id => site.id, :name => "" } }

      pending "will render thew :new view" do
        expect(response).to render_template(:new)
      end
    end
  end

  describe "PUT #update" do
   # before { update_params }

    context "when valid" do
      before { put :update, :post => { :name => "Site2" }, :id => first_component.id }

      pending "will redirect to spendinge_admin_components_path" do
        expect(response).to redirect_to(site_admin_components_path)
      end
    end

    context "when invalid" do
      before { put :update, :post => { :name => "" }, :id => first_component.id }

      pending "will render :edpending view" do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    before { delete :update, :id => first_component.id }

    pending "will redirect to spendinge_admin_components_path" do
      expect(response).to redirect_to(sites_admin_components_path)
    end

    pending "will flash[:success]" do
      expect(flash[:success]).to be_present
    end
  end
end
