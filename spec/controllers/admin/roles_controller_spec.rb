require "rails_helper"

describe Admin::RolesController do
  let(:user) { FactoryGirl.create(:user, is_admin: true) }
  let(:user_role) { FactoryGirl.create(:role) }

  before { sign_in user }

  describe "GET #index" do
    before { get :index }

    it "assigns @roles" do
      expect(assigns(:roles)).to eq([user_role])
    end

    it "renders the index view" do
      expect(response).to render_template(:index)
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

  describe "POST #create" do
    context "when valid" do
      before { post :create, role: { name: "Name" } }

      it "will redirect to admin_roles path" do
        expect(response).to redirect_to admin_roles_path
      end
    end
  end

  describe "PUT #update" do
    context "when success" do
      it "will redirect to admin_roles path" do
        expect(response).to be_success
      end
    end
  end

  describe "DELETE #destroy" do
    before(:each) {
      request.env["HTTP_REFERER"] = "/admin/roles"
      delete :destroy, :id => user_role.id
    }

    it "will redirect to admin_roles_path" do
      expect(response).to redirect_to "/admin/roles"
    end
  end
end
