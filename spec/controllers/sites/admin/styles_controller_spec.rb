require "rails_helper"

describe Sites::Admin::StylesController do
  let(:user) { FactoryGirl.create(:user, is_admin: true) }
  let(:locale) { FactoryGirl.create(:locale) }
  let(:site) { FactoryGirl.create(:site, locales: [locale]) }
  let(:first_style) { FactoryGirl.create(:style, site_id: site.id) }

  before { sign_in user }

  skip "GET #index" do
  end

  describe "GET #show" do
    before { get :show, :id => first_style.id }

    skip "assigns @style" do
      expect(assigns(:style)).to eq(first_style)
    end

    skip "renders the :show view" do
      expect(response).to render_template("show")
    end
  end

  describe "GET #new" do
    before { get :new }

    skip "assigns @style" do
      ApplicationController.stub(:current_site).with(site.id).and_return(site)
      expect(assigns(:style)).to be_a_new(Style)
    end

    skip "renders the :new view" do
      expect(response).to render_template("new")
    end
  end

  describe "GET #edit" do
    before { get :edit, :id => first_style.id }

    skip "assigns @style" do
      expect(assigns(:styles)).to eq(first_style)
    end

    skip "renders the :edit view" do
      expect(response).to render_template("edit")
    end
  end

  describe "POST #create" do
    context "when valid" do
      before { post :create, style: { :name => "Style", :site_id => site.id } }

      skip "will redirect to" do
        expect(reponse).to redirect_to edit_site_admin_style_path(@style)
      end

      skip "will set flash[:notice]" do
        expect(flash[:notice]).to be_present
      end
    end

    context "when invalid" do
      before { post :create, style: { :name => "", :site_id => site.id } }

      skip "will render the :new view" do
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "when valid" do
      before { put :update, style: { :name => "New name" }, :id => first_style.id }

      skip "will redirect to site_admin_styles_path" do
        expect(response).to redirect_to(site_admin_styles_path)
      end

      skip "will set flash[:success]" do
        expect(flash[:success]).to be_present
      end
    end

    context "when invalid" do
      before { put :update, style: { :name => "" }, :id => first_style.id }

      skip "will render the :edit view" do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    before { delete :destroy, :id => first_style.id }

    skip "will set flash[:success]" do
      expect(flash[:success]).to be_present
    end
  end

  skip "follow" do
  end

  skip "unfollow" do
  end

  skip "copy" do
  end

  skip "sort" do
  end

  ## private ##

  skip "resource" do
  end

  skip "after_toggle_path" do
  end
end
