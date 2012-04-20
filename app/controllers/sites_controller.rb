class SitesController < ApplicationController
  layout :choose_layout
  before_filter :require_user, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :check_authorization, :except => [:show, :index]
  respond_to :html, :xml, :js

  helper_method :sort_column

  def index
    params[:per_page] ||= Setting.get(:per_page_default)

    @sites = Site.name_or_description_like(params[:search]).
      except(:order).
      order(sort_column + " " + sort_direction).
      page(params[:page]).
      per(params[:per_page])
    unless @sites
      flash[:warning] = (t"none_param", :param => t("page.one"))
    end
  end

  def show
    if(@site)
      params[:site_id] = @site.name
      params[:id] = @site.id
      params[:per_page] = nil
    else
      catcher
    end
  end

  def new
    @site = Site.new
    @themes = []
    (Dir[File.join(Rails.root + "app/views/layouts/[a-zA-Z]*.erb")] - Dir[File.join(Rails.root + "app/views/layouts/application.html.erb")]).each do |file|
      @themes << file.split("/")[-1].split(".")[0]
    end
  end

  def edit
    @repositories = Repository.search(params[:search], params[:page],["archive_content_type LIKE ?","image%"])
    @site = Site.find_by_name(params[:id])
  end

  def create
    @site = Site.new(params[:site])
    if @site.theme == 'this2'
      # TODO mover o código a seguir para um lugar melhor (um yml talvez)
      @site.components << [
      Component.new({:place_holder=>'first_place',:settings=>'{:background => "#7F7F7F"}',:component=>'gov_bar', :position=>1, :publish=>true}),
      Component.new({:place_holder=>'first_place',:settings=>'{}', :component=>'weby_bar', :position=>2, :publish=>true}),
      Component.new({:place_holder=>'first_place',:settings=>'{}', :component=>'institutional_bar', :position=>3, :publish=>true}),
      Component.new({:place_holder=>'top', :settings=>'{}', :component=>'header', :position=>4, :publish=>true}),
      Component.new({:place_holder=>'top', :settings=>'{:category => "menu1"}', :component=>'menu_side', :position=>5, :publish=>true}),
      Component.new({:place_holder=>'top', :settings=>'{}', :component=>'menu_accessibility',:position=>6, :publish=>true}),
      Component.new({:place_holder=>'right', :settings=>'{:category => "menu4"}', :component=>'menu_side', :position=>7, :publish=>true}),
      Component.new({:place_holder=>'right', :settings=>'{:category => "dir"}', :component=>'banner_side', :position=>8, :publish=>true}),
      Component.new({:place_holder=>'bottom', :settings=>'{:category => "menu3"}', :component=>'menu_side', :position=>9, :publish=>true}),
      Component.new({:place_holder=>'bottom', :settings=>'{}', :component=>'info_footer', :position=>10,:publish=>true}),
      Component.new({:place_holder=>'bottom', :settings=>'{}', :component=>'feedback', :position=>11,:publish=>true}),
      Component.new({:place_holder=>'left', :settings=>'{:category => "menu2"}', :component=>'menu_side', :position=>12,:publish=>true}),
      Component.new({:place_holder=>'left', :settings=>'{:category => "esq"}', :component=>'banner_side', :position=>13,:publish=>true}),
      Component.new({:place_holder=>'home', :settings=>'{:quant => "5"}', :component=>'front_news', :position=>14,:publish=>true}),
      Component.new({:place_holder=>'home', :settings=>'{:quant => "5"}', :component=>'no_front_news', :position=>15,:publish=>true})
      ]
    end
    if @site.save
      redirect_to site_components_path(@site)
    else
      @themes = []
      (Dir[File.join(Rails.root + "app/views/layouts/[a-zA-Z]*.erb")] - Dir[File.join(Rails.root + "app/views/layouts/application.html.erb")]).each do |file|
        @themes << file.split("/")[-1].split(".")[0]
      end
      respond_with @site
    end
  end

  def update
    @site = Site.find_by_name(params[:id])
    if @site.update_attributes(params[:site])
      flash[:notice] = t"successfully_updated"
    end
    redirect_to edit_site_admin_path(@site, @site)
  end

  def destroy
    @site = Site.find_by_name(params[:id])
    @site.destroy
    respond_with(@site)
  end

  private
  def sort_column
    Site.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end
end
