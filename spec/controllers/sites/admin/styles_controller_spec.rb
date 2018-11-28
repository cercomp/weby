require "rails_helper"

describe Sites::Admin::StylesController do
  let(:user) { FactoryGirl.create(:user, is_admin: true) }
  let(:locale) { FactoryGirl.create(:locale) }
  let(:site) { FactoryGirl.create(:site, locales: [locale]) }
  let(:skin) { FactoryGirl.create(:skin, site_id: site.id, active: true) }
  let(:first_style) { FactoryGirl.create(:style, skin_id: skin.id) }
  let(:new_site) { FactoryGirl.create(:site, locales: [locale]) }

  before do
    @request.host = "#{site.name}.example.com"
    sign_in user
  end


  describe "GET #index" do
    before { get :index }

    it "renders the :index view" do
      expect(response).to redirect_to(site_admin_skins_path(anchor: 'tab-styles'))
    end
  end

  describe "GET #show" do
    before { get :show, :id => first_style.id }

    it "assigns @style" do
      expect(assigns(:style)).to eq(first_style)
    end

    it "renders the :show view" do
      expect(response).to render_template("show")
    end
  end

  describe "GET #new" do
    before do
      get :new
    end

    it "assigns @style" do
      expect(assigns(:style)).to be_a_new(Style)
    end

    it "renders the :new view" do
      expect(response).to render_template("new")
    end
  end

  describe "POST #create" do
    context "when valid" do
      before { post :create, style: { :name => "Style", :skin_id => skin.id } }

      it "will redirect to" do
        expect(response).to redirect_to edit_site_admin_skin_style_path(skin, assigns(:style), subdomain: site.name)
      end

      it "will set flash[:notice]" do
        expect(flash[:success]).to be_present
      end
    end

    context "when invalid" do
      before { post :create, style: { :name => "", :skin_id => skin.id } }

      it "will render the :new view" do
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "when valid" do
      before { put :update, style: { :name => "New name" }, :id => first_style.id }

      it "will redirect to site_admin_skins_path" do
        expect(response).to redirect_to(site_admin_skins_path(anchor: 'tab-styles'))
      end

      it "will set flash[:success]" do
        expect(flash[:success]).to be_present
      end
    end

    context "when invalid" do
      before { put :update, style: { :name => "" }, :id => first_style.id }

      it "will render the :edit view" do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    before { delete :destroy, :id => first_style.id }

    it "will set flash[:success]" do
      expect(flash[:success]).to be_present
    end
  end

  describe "follow" do
    before { put :follow, id: first_style.id }

    skip"will follow a style" do
      expect(response).to redirect_to(follow_site_admin_style_path(first_style.id, subdomain: new_site.name))
    end
  end

  describe "unfollow" do
    skip "will unfollow a style" do
      expect(response).to redirect_to(unfollow_site_admin_style_path(first_style.id, subdomain:
                                                                     new_site.name))
    end
  end

  describe "copy" do
    context "when valid" do
      before { put :copy, id: first_style.id }

      skip "will copy a style" do
      end

      skip "will set flash[:success]" do
        expect(flash[:success]).to be_present
      end

      it "will redirect to site_admin_skins_path" do
        expect(response).to redirect_to(site_admin_skins_path(anchor: 'tab-styles'))
      end
    end

    context "when invalid" do
      before { put :copy, id: first_style.id }

      it "will set flash[:error]" do
        expect(flash[:error]).to be_present
      end

      it "will redirect to site_admin_skins_path" do
        expect(response).to redirect_to(site_admin_skins_path(anchor: 'tab-styles'))
      end
    end
  end

  describe "sort" do
    let(:sec_style) { FactoryGirl.create(:style, site_id: site.id) }

    before { post :sort }

    skip "will allow sorting the styles" do
    end
  end
end
