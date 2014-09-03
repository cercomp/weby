require "rails_helper"

describe Sites::Admin::Menus::MenuItemsController do
  let(:user) { FactoryGirl.create(:user, is_admin: true) }
  let(:menu) { FactoryGirl.create(:menu, site_id: site.id) }

  describe "GET #index" do
    skip "will redirect to spendinge_admin_menus" do
      expect(response).to redirect_to(site_admin_menus_path(menu: menu.id))
    end
  end

  describe "GET #show" do
    skip "will redirect to spendinge_admin_menus" do
      expect(response).to redirect_to(site_admin_menus_path(menu: menu.id))
    end
  end

  skip "GET #new" do
  end

  skip "GET #edit" do
  end

  skip "POST #create" do
  end

  skip "PUT #update" do
  end

  skip "DELETE #destroy" do
  end

  skip "change_order" do
  end

  skip "change_menu" do
  end

  ## private ##

  skip "get_current_menu" do
  end

  skip "set_parent_menu_item(parend_id)" do
  end

  skip "resource" do
  end
end
