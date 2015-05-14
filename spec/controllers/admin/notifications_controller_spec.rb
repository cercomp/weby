require "rails_helper"

describe Admin::NotificationsController do
  let(:user) { FactoryGirl.create(:user, is_admin: true) }
  let!(:notifi) { FactoryGirl.create(:notification, body: "Body") }

  before { sign_in user }

  describe "GET #index" do
    before { get :index }

    skip "should populate an array with all notifications" do
      notifi = Notification.all
      get :index
      expect(assigns(:notifications)).to eq(notifi)
    end

    it "renders the :index view" do
      expect(response).to render_template(:index)
    end
  end

  describe "GET #new" do
    before { get :new }

    it "assigns @notification" do
      expect(assigns(:notification)).to be_a_new(Notification)
    end

    it "renders the :new view" do
      expect(response).to render_template(:new)
    end
  end

  describe "GET #show" do
    before { get :show, :id => notifi.id }

    it "assigns @notification" do
      expect(assigns(:notification)).to eq(notifi)
    end

    it "renders the :edit view" do
      expect(response).to render_template(:show)
    end
  end

  describe "GET #show" do
    before { get :show, :id => notifi.id }

    it "assigns @notification" do
      expect(assigns(:notification)).to eq(notifi)
    end

    it "renders the :show view" do
      expect(response).to render_template(:show)
    end
  end

  describe "POST #create" do
    context "when valid" do
      before { post :create, notificaion: { title: "Title", body: "Body" } }

      skip "will redirect to notification path" do
        expect(response).to redirect_to admin_notification_path(notifi)
      end

      skip "will set flash[:alert]" do
        expect(flash[:alert]).to be_present
      end

      skip "will record activity" do
      end
    end

    context "when not valid" do
      before { post :create, notification: { title: "Title", body: "" } }

      it "will render :new view" do
        expect(response).to render_template(:new)
      end

      it "will set flash[:alert]" do
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "PUT #update" do
    context "when success" do
      before { put :update, notification: { title: "Updated Body", body: "Updated Body" },
               id: notifi.id }

      it "will redirect to notification path" do
        expect(response).to redirect_to admin_notification_path(notifi)
      end
    end

    context "when not success" do
      before { put :update, post: { :title => "", :body => "" }, :id => notifi.id }

      skip "will set flash[:error]" do
        expect(flash[:error]).to be_present
      end

      skip "will render :index template" do
        expect(response).to render_template(:index)
      end
    end
  end

  describe "DELETE #destroy" do
    before { delete :destroy, :id => notifi.id }

    it "will redirect to notifications path" do
      expect(response).to redirect_to admin_notifications_path
    end
  end
end
