# encoding: UTF-8
class Admin::SitesController < ApplicationController
  before_filter :require_user, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :check_authorization, :except => [:show, :index]
  respond_to :html, :xml, :js

  helper_method :sort_column

  def index
    params[:per_page] ||= current_settings[:per_page_default]

    @sites = Site.name_or_description_like(params[:search]).
      except(:order).
      order(sort_column + " " + sort_direction).
      page(params[:page]).
      per(params[:per_page])
    flash[:warning] = (t"none_page") unless @sites
  end

  def new
    @site = Site.new
    @themes = []
    (Dir[File.join(Rails.root + "app/views/layouts/[a-zA-Z]*.erb")] - Dir[File.join(Rails.root + "app/views/layouts/application.html.erb")] - Dir[File.join(Rails.root + "app/views/layouts/sites.html.erb")] - Dir[File.join(Rails.root + "app/views/layouts/session.html.erb")]).each do |file|
      @themes << file.split("/")[-1].split(".")[0]
    end
  end

  def create
    @site = Site.new(params[:site])
    if @site.save

      # TODO mover o código a seguir para um lugar melhor (um yml talvez)
      if @site.theme == 'this2'

        menu_top    = @site.menus.create({:name => 'Menu Superior'})
        menu_left   = @site.menus.create({:name => 'Menu Esquerdo'})
        menu_right   = @site.menus.create({:name => 'Menu Direito'})
        menu_bottom = @site.menus.create({:name => 'Menu Inferior'})

        @site.components.create({:place_holder=>'first_place',:settings=>'{:background => "#7F7F7F"}',:name=>'gov_bar', :position=>1, :publish=>true})
        @site.components.create({:place_holder=>'first_place',:settings=>'{}', :name=>'institutional_bar', :position=>2, :publish=>true})
        @site.components.create({:place_holder=>'top', :settings=>'{:size=>"original", :width=>"", :height=>"", :url=>"/", :target_id=>"", :target_type=>"", :repository_id=>"", :html_class => "header", :new_tab=>"0"}', :name=>'image', :position=>1, :alias=>"Cabeçalho(Topo)", :publish=>true})
        @site.components.create({:place_holder=>'top', :settings=>"{:menu_id => \"#{menu_top.id}\"}", :name=>'menu', :position=>2, :publish=>true})
        @site.components.create({:place_holder=>'top', :settings=>'{}', :name=>'menu_accessibility',:position=>3, :publish=>true})
        @site.components.create({:place_holder=>'left', :settings=>"{:menu_id => \"#{menu_left.id}\"}", :name=>'menu', :position=>1,:publish=>true})
        @site.components.create({:place_holder=>'left', :settings=>'{:category => "esq", :orientation => "vertical"}', :name=>'banner_list', :position=>2,:publish=>true})
        @site.components.create({:place_holder=>'right', :settings=>"{:width => \"\", :align => \"left\"}", :name=>'search_box', :position=>1, :publish=>true})
        @site.components.create({:place_holder=>'right', :settings=>"{:menu_id => \"#{menu_right.id}\"}", :name=>'menu', :position=>2, :publish=>true})
        @site.components.create({:place_holder=>'right', :settings=>'{:category => "dir", :orientation => "vertical"}', :name=>'banner_list', :position=>3, :publish=>true})
        @site.components.create({:place_holder=>'bottom', :settings=>"{:menu_id => \"#{menu_bottom.id}\"}", :name=>'menu', :position=>1, :publish=>true})
        @site.components.create({:place_holder=>'bottom', :settings=>"{:body => \"#{t("admin.sites.form.footer_text")}\", :html_class => \"footer\"}", :name=>'text', :position=>2, :alias=>'Rodapé', :publish=>true})
        @site.components.create({:place_holder=>'bottom', :settings=>'{}', :name=>'feedback', :position=>3,:publish=>true})
        @site.components.create({:place_holder=>'home', :settings=>'{:quant => "5"}', :name=>'front_news', :position=>1,:publish=>true})
        @site.components.create({:place_holder=>'home', :settings=>'{:quant => "5"}', :name=>'news_list', :position=>2,:publish=>true})
         
      end
      puts "site criado #{@site.inspect}"
      redirect_to site_admin_components_url(subdomain: @site)
    else
      @themes = []
      (Dir[File.join(Rails.root + "app/views/layouts/[a-zA-Z]*.erb")] - Dir[File.join(Rails.root + "app/views/layouts/application.html.erb")]).each do |file|
        @themes << file.split("/")[-1].split(".")[0]
      end
      respond_with @site
    end
  end

  def edit
    @site = Site.find_by_name(params[:id])
    load_themes
    puts "HERE??"
  end

  def update
    @site = Site.find_by_name(params[:id])
    if @site.update_attributes(params[:site])
      flash[:success] = t"successfully_updated"
      redirect_to admin_sites_path
    else
      load_themes
      render :edit
    end
  end

  def destroy
    #@site = Site.find_by_name(params[:id])
    #@site.destroy
    #respond_with(:admin, @site)
  end

  private
  def sort_column
    Site.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def load_themes
    @themes = []
    (Dir[File.join(Rails.root + "app/views/layouts/[a-zA-Z]*.erb")] -
     Dir[File.join(Rails.root + "app/views/layouts/application.html.erb")] -
     Dir[File.join(Rails.root + "app/views/layouts/sites.html.erb")] -
     Dir[File.join(Rails.root + "app/views/layouts/session.html.erb")]).each do |file|
       @themes << file.split("/")[-1].split(".")[0]
     end
  end
end
