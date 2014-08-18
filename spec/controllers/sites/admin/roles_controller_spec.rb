require "spec_helper"

describe Sites::Admin::RolesController do
  let(:user) { FactoryGirl.create(:user, is_admin: true) }
  let(:locale) { FactoryGirl.create(:locale) }
  let(:site) { FactoryGirl.create(:site, locales: [locale]) }
  let(:role) { FactoryGirl.create(:role) }

 before { sign_in user }

  describe "GET #index" do
  end

  describe "GET #show" do
  end

  describe "GET #new" do
  end

  describe "GET #edit" do
  end

  describe "POST #create" do
  end

  describe "PUT #update" do
  end

  describe "DELETE #destroy" do
  end
end
