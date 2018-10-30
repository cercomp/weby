require "rails_helper"

describe Admin::UsersController do
  let(:first_user) { FactoryGirl.create(:user, is_admin: true) }
  let(:_user) { FactoryGirl.create(:user) }

  before { sign_in first_user }

  describe "GET #index" do
    before { get :index }

    it "assigns @users" do
      expect(assigns(:users)).to eq([first_user])
    end

    it "renders the :index view" do
      expect(response).to render_template(:index)
    end
  end

  describe "GET #new" do
    before { get :new }

    it "assigns @user" do
      expect(assigns(:user)).to be_a_new(User)
    end

    it "renders the :new view" do
      expect(response).to render_template(:new)
    end
  end

  describe "GET #show" do
    before { get :show, :id => first_user.id }

    it "assigns @user" do
      expect(assigns(:user)).to eq(first_user)
    end

    it "renders the :show view" do
      expect(response).to render_template(:show)
    end
  end

  describe "GET #show" do
    before { get :show, :id => first_user.id }

    it "assigns @user" do
      expect(assigns(:user)).to eq(first_user)
    end

    it "renders the :edit view" do
      expect(response).to render_template(:show)
    end
  end

  describe "POST #create" do
    context "when valid" do
      before { post :create, :user => { :login => "Username", :email => "email@example.com"  } }

      it "will redirect to admin_user path" do
        expect(response).to be_successful
      end

      skip "will set flash[:success]" do
        expect(flash[:success]).to be_present
      end
    end

    context "when invalid" do
      before { post :create, :user => { :login => "", :email => "" } }

      it "will render :new view" do
        expect(response).to render_template(:new)
      end

      it "will set flash[:error]" do
        expect(flash[:error]).to be_present
      end
    end
  end

  describe "PUT #update" do
    before { patch :update, id: _user, user: { :login => "updated", :email => "email@updated.com" } }

    it "will set flash[:success]" do
      expect(flash[:success]).to eq ' Conta atualizada, um email foi enviado para confirmar o novo endereço de email'
    end
  end

  describe "DELETE #destroy" do
    before { delete :destroy, :id => _user.id }

    skip "will redirect to admin_users_path" do
      expect(response).to redirect_to admin_users_path
    end

    skip "will set flash[:success]" do
      expect(flash[:success]).to be_present
    end
  end

  skip "change_roles" do
  end

  skip "manage_roles" do
  end

  ## private ##

  skip "sort_column" do
  end

  skip "toggle_attribute!" do
  end
end
