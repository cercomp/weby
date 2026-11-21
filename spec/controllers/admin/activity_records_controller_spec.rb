require "rails_helper"

describe Admin::ActivityRecordsController do
  let(:user) { FactoryBot.create(:user, is_admin: true) }

  before { sign_in user }

  describe "GET #index" do
    it "renders all records" do
      record = FactoryBot.create(:activity_record, user: user)
      get :index

      expect(assigns(:activity_records)).to eq([record])
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    it "render the record" do
      activity = FactoryBot.create(:activity_record, user: user)
      get :show, id: activity

      expect(assigns(:activity_record)).to eq(activity)
      expect(response).to render_template(:show)
    end
  end

  describe "DELETE #destroy" do
    it "deletes the activity record" do
      activity = FactoryBot.create(:activity_record, user: user)

      expect { delete :destroy, id: activity }.to change(ActivityRecord, :count).by(-1)
      expect(response).to redirect_to admin_activity_records_path
    end
  end
end
