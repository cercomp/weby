require "rails_helper"

describe Sites::Admin::UsersController do
  let(:user) { FactoryGirl.create(:user, is_admin: true) }
  let(:locale) { FactoryGirl.create(:locale) }
  let(:site) { FactoryGirl.create(:site, locales: [locale]) }
  let(:role) { FactoryGirl.create(:role) }

  before do
    @request.host = "#{site.name}.example.com"
    sign_in user
  end

  describe "change_roles" do
    before { post :change_roles }

    skip "will redirect to action manage_roles" do
      expect(response).to redirect_to change_roles_site_admin_users_path(subdomain: site.name)
    end
  end

  describe "create_local_admin_role" do
    before { post :create_local_admin_role }

    skip "will redirect to action manage_roles" do
      expect(response).to redirect_to change_roles_site_admin_users_path(subdomain: site.name)
    end
  end

  describe "destroy_local_admin_role" do
    before { post :create, role: { :name => "Admin", :site_id => site.id, :permissions => "Admin" } }

    skip "will destroy a role with 'Admin' permission" do
      expect do
        delete :destroy_local_admin_role
      end.to change(Role, :count)
    end

    skip "will redirect to action manage_roles" do
      delete :destroy_local_admin_role

      expect(response).to redirect_to change_roles_site_admin_users_path(subdomain: site.name)
    end
  end

  describe "manage_roles" do
    before { get :manage_roles }

    skip "assigns @site_users" do
      expect(assigns(:site_user)).to eq([user])
    end

    skip "assigns @users_unroled" do
      expect(assigns(:users_unroled)).to eq([user])
    end

    skip "assigns @site_admins" do
      expect(assigns(:site_admins)).to eq([user])
    end

    skip "assigns @roles" do
      expect(assigns(:roles)).to eq([role])
    end

    skip "assigns @user" do
      expect(assigns(:user)).to eq(user)
    end
  end
end
