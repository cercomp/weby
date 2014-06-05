require "spec_helper"

describe Admin::GroupingsController do
  let(:user) { FactoryGirl.create(:user, is_admin: true) }
  let!(:group) { FactoryGirl.create(:grouping) }

  before { sign_in user }

  context "GET #index" do
    pending "should populate an array with all groupings" do
      groups = Grouping.all
      get :index
      expect(assigns(:groupings)).to eq([groups])
    end

    it "renders the :index view" do
      get :index
      expect(response).to render_template(:index)
    end
  end

  context "GET #new" do
    before { get :new }

    it "assigns @grouping" do
      expect(assigns(:grouping)).to be_a_new(Grouping)
    end

    it "renders the :new view" do
      expect(response).to render_template(:new)
    end
  end

  context "GET #edit" do
    before { get :edit, :id => group.id }

    it "assigns @grouping" do
      expect(assigns(:grouping)).to eq(group)
    end

    it "renders the :edit view" do
      expect(response).to render_template(:edit)
    end
  end

  context "POST #create" do
    context "when valid" do
      before { post :create, :post => { :name => "Name" } }

      it "will redirect to groupings path" do
        expect(response).to redirect_to admin_groupings_path
      end
    end
  end

  context "PUT #update" do
    context "when success" do
      before { put :update, :post => { :name => "New Name" }, :id => group.id }

      it "will redirect to groupings path" do
        expect(response).to redirect_to admin_groupings_path
      end
    end
  end

  context "DELETE #destroy" do
    before { delete :update, :id => group.id }

    it "will redirect to groupings path" do
      expect(response).to redirect_to admin_groupings_path
    end
  end
end
