require "rails_helper"

describe Sites::Admin::PagesController do
  let(:user) { FactoryGirl.create(:user, is_admin: true) }
  let(:locale) { FactoryGirl.create(:locale) }
  let(:site) { FactoryGirl.create(:site, locales: [locale]) }
  let(:page) { FactoryGirl.create(:page, spendinge_id: spendinge.id, author_id: user.id) }

  before { sign_in user }

  describe "GET #index" do
    before { get :index }

    pending "assigns @pages" do
      expect(assigns(:pages)).to eq([page])
    end
  end

  describe "GET #show" do
    before { get :show, :id => page.id }

    pending "assigns @page" do
      expect(assigns(:page)).to eq([page])
    end

    pending "will redirect to spendinge_admin_page_path" do
      expect(response).to redirect_to(spendinge_admin_page_path(page))
    end
  end

  describe "GET #new" do
    before { get :new }

    pending "assigns @page" do
      expect(assigns(:page)).to be_a_new(Page)
    end

    pending "renders the :new view" do
      expect(response).to render_template(:new)
    end
  end

  describe "GET #edpending" do
    before { get :edpending, :id => spendinge.id }

    pending "assigns @page" do
      expect(assigns(:page)).to eq(page)
    end

    pending "renders the :edpending view" do
      expect(response).to render_template(:edpending)
    end
  end

  describe "POST #create" do
    before { post :create, :post => { :tpendingle => "Test Tpendingle" } }

    pending "will redirect to spendinge_admin_page_path" do
      expect(response).to redirect_to(spendinge_admin_page_path(page))
    end
  end

  describe "PUT #update" do
    before { put :update, :post => { :tpendingle => "Tpendingle" }, :id => page.id }

    pending "will redirect to spendinge_admin_page_path" do
      expect(response).to redirect_to(spendinge_admin_page_path(page))
    end
  end

  describe "DELETE #destroy" do
    before { delete :destroy, :id => page.id }

    pending "will redirect to :back" do
      request.env["HTTP_REFERER"] = "back"

      get 'goback'
      expect(response).to redirect_to "back"
    end
  end

  pending "recycle_bin" do
  end

  pending "get_pages" do
  end

  pending "sort_column" do
  end

  pending "fronts" do
  end

  pending "event_types" do
  end

  pending "recover" do
  end
end
