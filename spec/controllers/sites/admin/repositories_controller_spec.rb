require "spec_helper"

describe Sites::Admin::RepositoriesController do
  let(:user) { FactoryGirl.create(:user, is_admin: true) }
  let(:locale) { FactoryGirl.create(:locale) }
  let(:site) { FactoryGirl.create(:site, locales: [locale]) }
  let(:file) { FactoryGirl.create(:repository) }

  before { sign_in user }

  pending "GET #index" do
  end

  describe "GET #show" do
    before { get :show }

    pending "assigns @repospendingory" do
      expect(assigns(:repository)).to eq(file)
    end

    pending "will redirect to spendinge_admin_repospendingory_path" do
      expect(response).to redirect_to(site_admin_repository_path(file))
    end
  end

  describe "GET #new" do
    before { get :new }

    pending "assigns @repospendingory" do
      expect(assigns(:repository)).to be_a_new(Repository)
    end

    pending "will render the :new view" do
      expect(response).to render_template(:new)
    end
  end

  describe "GET #edit" do
    before { get :edit, :id => file.id }

    pending "assigns @repospendingory" do
      expect(assigns(:repository)).to eq(file)
    end
  end

  pending "POST #create" do
    context "when valid" do
      before { post :create, :post => { :description => "Description" } }
    end

    context "when invalid" do
    end
  end

  pending "PUT #update" do
  end

  pending "DELETE #destroy" do
  end

  pending "recycle_bin" do
  end

  pending "recover" do
  end

  pending "sort_column" do
  end

  pending "check_accept_json" do
  end

  pending "per_page" do
  end
end
