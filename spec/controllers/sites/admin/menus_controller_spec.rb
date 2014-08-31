require "rails_helper"

describe Sites::Admin::MenusController do
  let(:user) { FactoryGirl.create(:user, is_admin: true) }
  let(:locale) { FactoryGirl.create(:locale) }
  let(:site) { FactoryGirl.create(:site, locales: [locale]) }
  let(:menu) { FactoryGirl.create(:menu, site_id: site.id) }

  before { sign_in user }

  pending "GET #index" do
    before { get :index }
  end

  describe "GET #show" do
    before { get :show, :id => menu.id }

    pending "will redirect to spendinge_admin_menus_path" do
      expect(response).to redirect_to(site_admin_menus_path(:menu => params[:id]))
    end
  end

  describe "GET #new" do
    before { get :new }

    it "assigns @menu" do
      expect(assigns(:menu)).to be_a_new(Menu)
    end
  end

  describe "GET #edit" do
    before { get :edit, :id => menu.id }

    pending "assigns @menu" do
      expect(assigns(:menu)).to eq(menu)
    end

    pending "renders the :edpending view" do
      expect(response).to render_template(:edit)
    end
  end

  describe "POST #create" do
    context "when valid" do
      before { post :create, :post => { :name => "Name" } }

      pending "will redirect to spendinge_admin_menus_path" do
        expect(response).to redirect_to(site_admin_menus_path(:menu => menu.id))
      end

      pending "will set flash[:success]" do
        expect(flash[:success]).to be_present
      end
    end

    context "when invalid" do
      before { post :create, :post => { :name => "Name" } }

      pending "will redirect to spendinge_admin_menus_path" do
        expect(response).to redirect_to(site_admin_menus_path)
      end
    end
  end

  describe "PUT #update" do
    context "when valid" do
      before { put :update, :post => { :name => "Name2" }, :id => menu.id }

      pending "redirect to spendinge_admin_menus_path" do
        expect(response).to redirect_to(site_admin_menus_path(:menu => menu.id))
      end

      pending "will set flash[:success]" do
        expect(flash[:success]).to be_present
      end
    end

    context "when invalid" do
      before { put :update, :post => { :name => "" }, :id => menu.id }

      pending "will redirect to spendinge_admin_menus_path" do
        expect(response).to redirect_to(site_admin_menus_path)
      end
    end
  end

  describe "DELETE #destroy" do
    before { delete :destroy, :id => menu.id }

    pending "will redirect to spendinge_admin_menus_path" do
      expect(response).to redirect_to(site_admin_menus_path)
    end

    pending "will set flash[:success]" do
      expect(flash[:success]).to be_present
    end
  end
end
