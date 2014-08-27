require "spec_helper"

describe Sites::Admin::Menus::MenuItemsController do
  let(:user) { FactoryGirl.create(:user, is_admin: true) }
  let(:menu) { FactoryGirl.create(:menu, site_id: site.id) }

  describe "GET #index" do
    pending "will redirect to spendinge_admin_menus" do
      expect(response).to redirect_to(site_admin_menus_path(menu: menu.id))
    end
  end

  describe "GET #show" do
    pending "will redirect to spendinge_admin_menus" do
      expect(response).to redirect_to(site_admin_menus_path(menu: menu.id))
    end
  end

  pending "GET #new" do
  end

  pending "GET #edit" do
  end

  pending "POST #create" do
  end

  pending "PUT #update" do
  end

  pending "DELETE #destroy" do
  end

  pending "change_order" do
  end

  pending "change_menu" do
  end

  ## private ##

  pending "get_current_menu" do
  end

  pending "set_parent_menu_item(parend_id)" do
  end

  pending "resource" do
  end
end
