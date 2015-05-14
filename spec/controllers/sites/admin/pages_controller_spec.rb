require "rails_helper"

describe Sites::Admin::PagesController do
  let(:user) { FactoryGirl.create(:user, is_admin: true) }
  let(:locale) { FactoryGirl.create(:locale) }
  let(:site) { FactoryGirl.create(:site, locales: [locale]) }
  let(:page) { FactoryGirl.create(:page, site_id: site.id, user_id: user.id) }

  before { sign_in user }

  describe "GET #index" do
    before { get :index }

    skip "assigns @pages" do
      expect(assigns(:pages)).to eq([page])
    end
  end

  describe "GET #show" do
    before { get :show, :id => page.id }

    skip "assigns @page" do
      expect(assigns(:page)).to eq([page])
    end

    skip "will redirect to site_admin_page_path" do
      expect(response).to redirect_to(site_admin_page_path(page))
    end
  end

  describe "GET #new" do
    before { get :new }

    skip "assigns @page" do
      expect(assigns(:page)).to be_a_new(Page)
    end

    skip "renders the :new view" do
      expect(response).to render_template(:new)
    end
  end

  describe "GET #show" do
    before { get :show, :id => site.id }

    skip "assigns @page" do
      expect(assigns(:page)).to eq(page)
    end

    skip "renders the :edit view" do
      expect(response).to render_template(:edskip)
    end
  end

  describe "POST #create" do
    before { post :create, :post => { :title => "Test Title" } }

    skip "will redirect to site_admin_page_path" do
      expect(response).to redirect_to(site_admin_page_path(page))
    end
  end

  describe "PUT #update" do
    before { put :update, :post => { :title => "Title" }, :id => page.id }

    skip "will redirect to site_admin_page_path" do
      expect(response).to redirect_to(site_admin_page_path(page))
    end
  end

  describe "DELETE #destroy" do
    before { delete :destroy, :id => page.id }

    skip "will redirect to :back" do
      request.env["HTTP_REFERER"] = "back"

      get 'goback'
      expect(response).to redirect_to "back"
    end
  end

  skip "recycle_bin" do
  end

  skip "get_pages" do
  end

  skip "sort_column" do
  end

  skip "fronts" do
  end

  skip "event_types" do
  end

  skip "recover" do
  end
end
