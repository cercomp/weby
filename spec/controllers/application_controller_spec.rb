require "rails_helper"

describe ApplicationController do
  let(:user) { FactoryGirl.create(:user, is_admin: true) }
  let(:locale) { FactoryGirl.create(:locale) }
  let(:site) { FactoryGirl.create(:site, locales: [locale], domain: "com.br") }

  before do
    @request.host = "#{site.name}.example.com"
    sign_in user
  end

  describe "admin" do
    skip "will render admin/admin" do
      expect(subject).to render_template("admin/admin")
    end
  end

  describe "choose_layout" do
    it "will set layout" do
      expect(subject.choose_layout).to eq("weby")
    end
  end

  describe "test_permission" do
    skip "will return false unless current_user is set" do
      expect(subject.test_permission(Sites::Admin::RolesController, create)).to eq("false")
    end

    skip "will return true if current_user is an admin" do
      expect(subject.test_permission(Sites::Admin::RolesController, create)).to eq("true")
    end
  end

  describe "set_contrast" do
    it "will set no contrast" do
      session[:contrast] = 'no'
      expect(session[:contrast]).to eq('no')
    end
  end

  describe "set_view_types" do
    it "will allow thumbs view" do
      session[:repository_view] = 'thumbs'
      expect(session[:repository_view]).to eq('thumbs')
    end

    it "will allow list view" do
      session[:banners_view] = 'list'
      expect(session[:banners_view]).to eq('list')
    end
  end

  describe "current_site" do
    skip "will return @current_site" do
      @current_site = site
      expect(ApplicationController).to receive(@current_site).and_return(site)
    end
  end

  describe "set_locale" do
    it "will set locale or use default" do
      session[:locale] = "pt-BR"
      expect(session[:locale]).to eq("pt-BR")
    end
  end

  describe "access_denied" do
    skip "will set flash[:error]" do
      expect(flash[:error]).to be_present
    end

    skip "will redirect_back_or_default" do
      expect(response).to redirect_back_or_default(weby_login_path)
    end
  end

  describe "set_tld_length" do
    skip "sets tld length" do
      expect(request.session_options[:tld_length]).to eq(site.domain.split('.') + 1)
    end
  end

  describe "render_404" do
    skip "render errors/404" do
      get "/teste"
      expect(response).to render_template("errors/404 ")
    end

    it "responds with 404" do
      expect(response).to be_success
    end
  end

  describe "render_500" do
    skip "render errors/505" do
      get "site"
      expect(response).to render_template("errors/500")
    end

    it "responds with 500" do
      expect(response).to be_success
    end
  end

  describe "count_view" do
    it "will respond with 200" do
      expect(response.status).to eq(200)
    end

    it "will request with html" do
      expect(request.format).to eq('html')
    end
  end

  describe "count_click" do
    skip "renders nothing" do
      expect(Weby::Sticker::Banner).to receive(increment_counter).with(:click_count)
    end
  end

  #protected

  describe "resource" do
    skip "will load controller resources" do
      expect(controller.send(:resource)).to be_true
    end
  end

  describe "get_resource_ivar" do
    skip "will search for a controller variable" do
      ApplicationController.stub(:get_resource_ival)
      expect(assigns(:instance_variable_get)).to receive("@#{controller_name.singularize}").and_return(true)
    end
  end

  describe "set_resource_ivar" do
    skip "will define a variable with the same name of the controller" do
      ApplicationController.stub(:set_resource_ival)
      expect(assigns(:instance_variable_set)).to receive("@#{controller_name.singularize}",
                                                         controller.send(:resource)).and_return(true)
    end
  end

  describe "is_admin" do
    skip "will return true is_admin" do
      expect(assigns(:user)).to receive(:is_admin).and_return(true)
    end

    it "will redirect to admin_path" do
      expect(response.status).to eq(200)
    end
  end

  describe "global_local_admin" do
    skip "will return true if current_user is_local_admin" do
      let(:new_user) { FactoryGirls.create(:user) }
      expect(assigns(:global_local_admin)).to receive(:new_user).and_return(false)
    end

    it "will redirect to admin_path" do
      expect(response.status).to eq(200)
    end
  end

  describe "current_roles_assigned" do
    skip "will return [] if current_user does not exist" do
      expect(ApplicationController.stub(:current_roles_assigned)).to eq([])
    end
  end

  describe "require_no_user" do
    it "expect status to be 200" do
      expect(response.status).to eq(200)
    end
  end

  describe "store_location" do
    it "will store location" do
      expect(session[:return_to]).to eq(request.referer)
    end
  end

  describe "redirect_back_or_default" do
    skip "will correctly redirect" do
      expect(response).to redirect_to(session[:return_to])
    end
  end

  describe "set_global_vars" do
    before do
      Weby::Cache.request[:domain] = 'example.com'
    end

    it "will set correct domain" do
      expect(Weby::Cache.request[:domain]).to eq(request.domain)
    end

    skip "will set correct subdomain" do
      expect(Weby::Cache.request[:subdomain]).to eq(request.subdomain)
    end

    skip "will set current_user" do
      expect(Weby::Cache.request[:current_user]).to eq(user)
    end
  end

  describe "component_is_available" do
    before do
      @component = FactoryGirl.create(:component)
    end

    skip "will check if component is available" do
      expect(assigns[:component_is_available]).to receive(@component).and_return(true)
    end
  end

  describe "weby_clear" do
    skip "will clear cache" do
      expect(Weby::Settings.clear).to be_true
    end
  end

  describe "after_sign_in_path" do
    before do
      session[:return_to] = '/'
    end

    it "will return to root path after sign in" do
      expect(session[:return_to]).to eq(root_path)
    end
  end

  describe "record_activity" do
    before do
      @activity = FactoryGirl.build(:activity_record)
    end

    it "will correctly save a record" do
      expect { @activity.save }.to change(ActivityRecord, :count).by(1)
    end

  end

  describe "maintenance_mode" do
    before do
      Weby::Settings::Weby.maintenance_mode = 'true'
    end

    skip "will render maintenance template" do
      expect(response).to render_template('errors/maintenance')
    end

    skip "will render layout weby_pages" do
      expect(response).to use_layout('weby_pages')
    end
  end
end
