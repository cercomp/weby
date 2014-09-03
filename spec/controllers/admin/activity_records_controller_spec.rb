require "rails_helper"

describe Admin::ActivityRecordsController do
  let(:user) { FactoryGirl.create(:user, is_admin: true) }

  before { sign_in user }

  describe "GET #index" do
    skip "should populate an array of activities from the site being viewed" do
      record = FactoryGirl.create(:activity_record)
      get :index
      expect(assigns(:activity_records)).to eq([record])
    end

    it "renders the :index view" do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    it "assigns the request activity to @activity" do
      activity = ActivityRecord.create
      get :show, id: activity
      expect(assigns(:activity_record)).to eq(activity)
    end

    it "renders the :show view" do
      activity = ActivityRecord.create
      get :show, id: activity
      expect(response).to render_template(:show)
    end
  end

  describe "DELETE #destroy" do
    before :each do
      @activity = ActivityRecord.create
    end

    it "deletes the activity record" do
      expect {
        delete :destroy, id: @activity
      }.to change(ActivityRecord, :count).by(-1)
    end

    it "redirects to activityrecords#index" do
      delete :destroy, id: @activity
      expect(response).to redirect_to admin_activity_records_path
    end
  end
end
