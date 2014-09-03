require "rails_helper"

describe Sites::Admin::RolesController do
  let(:user) { FactoryGirl.create(:user, is_admin: true) }
  let(:locale) { FactoryGirl.create(:locale) }
  let(:site) { FactoryGirl.create(:site, locales: [locale]) }
  let(:role) { FactoryGirl.create(:role) }

 before { sign_in user }

  describe "GET #index" do
    before { get :index }

    skip "assigns @roles" do
      expect(assigns(:roles)).to eq([roles])
    end

    skip "renders the :index view" do
      expect(response).to render_template(:view)
    end
  end

  describe "GET #show" do
    before { get :show, :id => role.id }

    skip "assigns @role" do
      expect(assigns(:roles)).to eq([role])
    end

    skip "renders the :show view" do
      expect(response).to redirect_to(site_admin_role_path(:roles))
    end
  end

  describe "GET #new" do
    before { get :new }

    it "assigns @role" do
      expect(assigns(:role)).to be_a_new(Role)
    end

    it "renders the :new view" do
      expect(response).to render_template(:new)
    end
  end

  describe "GET #edit" do
    before { get :edit, :id => role.id }

    it "assigns @role" do
      expect(assigns(:role)).to eq(role)
    end
  end

  describe "POST #create" do
    before { post :create, :post => { :name => "Role" } }
  end

  describe "PUT #update" do
  end

  describe "DELETE #destroy" do
  end
end
