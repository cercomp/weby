require "rails_helper"

describe Admin::GroupingsController do
  before { sign_in FactoryGirl.create(:user, is_admin: true) }

  describe "GET #index" do
    it "renders groupings" do
      group = FactoryGirl.create(:grouping)

      get :index

      expect(response).to render_template(:index)
      expect(assigns(:groupings)).to match_array([group])
    end
  end

  describe "GET #new" do
    it "renders the :new view" do
      get :new

      expect(response).to render_template(:new)
      expect(assigns(:grouping)).to be_a_new(Grouping)
    end
  end

  describe "POST #create" do
    it "creates a new grouping" do
      post :create, grouping: { :name => "Name" }

      expect(Grouping.exists?(name: 'Name')).to be_truthy
      expect(response).to redirect_to admin_groupings_path
    end
  end

  describe "PUT #update" do
    it "updates the grouping" do
      group = FactoryGirl.create(:grouping)

      put :update, grouping: { :name => "New Name" }, :id => group.id

      expect(group.reload.name).to match('New Name')
      expect(response).to redirect_to admin_groupings_path
    end
  end

  describe "DELETE #destroy" do
    it "deletes the grouping" do
      group = FactoryGirl.create(:grouping)

      delete :destroy, :id => group.id

      expect(Grouping.exists?(group.id)).to be_falsy
      expect(response).to redirect_to admin_groupings_path
    end
  end
end
