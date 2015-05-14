require "rails_helper"

describe Sites::Admin::RepositoriesController do
  let(:user) { FactoryGirl.create(:user, is_admin: true) }
  let(:locale) { FactoryGirl.create(:locale) }
  let(:site) { FactoryGirl.create(:site, locales: [locale]) }
  let(:file) { FactoryGirl.create(:repository) }

  before { sign_in user }

  skip "GET #index" do
  end

  describe "GET #show" do
    before { get :show }

    skip "assigns @repository" do
      expect(assigns(:repository)).to eq(file)
    end

    skip "will redirect to site_admin_repository_path" do
      expect(response).to redirect_to(site_admin_repository_path(file))
    end
  end

  describe "GET #new" do
    before { get :new }

    skip "assigns @repository" do
      expect(assigns(:repository)).to be_a_new(Repository)
    end

    skip "will render the :new view" do
      expect(response).to render_template(:new)
    end
  end

  describe "GET #show" do
    before { get :show, :id => file.id }

    skip "assigns @repository" do
      expect(assigns(:repository)).to eq(file)
    end
  end

  skip "POST #create" do
    context "when valid" do
      before { post :create, :post => { :description => "Description" } }
    end
  end

  skip "PUT #update" do
  end

  skip "DELETE #destroy" do
  end

  skip "recycle_bin" do
  end

  skip "recover" do
  end

  skip "sort_column" do
  end

  skip "check_accept_json" do
  end

  skip "per_page" do
  end
end
