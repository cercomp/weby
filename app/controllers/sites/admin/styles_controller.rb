class Sites::Admin::StylesController < ApplicationController
  include ActsToToggle

  before_filter :require_user
  before_filter :check_authorization
  before_filter :resource, only: [:edit, :show]

  respond_to :html, :xml, :js
  
  def index
    @styles = {
      own: current_site.styles.by_name(params[:style_name]),
      other: Style.not_followed_by(current_site).by_name(params[:style_name]).
                page(params[:page]).per(params[:per_page])
    }
  end

  def new
    @style = current_site.styles.new
  end

  def create
    @style = current_site.styles.new(params[:style])
    if @style.save
      flash[:success] = t("successfully_created")
      record_activity("created_style", @style)
      redirect_to edit_site_admin_style_path(@style)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if resource.update_attributes(params[:style])
        record_activity("updated_style", resource)
        format.html do
          flash[:success] = t("successfully_updated")
          redirect_to site_admin_styles_path
        end
      else
        format.html { render 'edit' }
      end
      format.json { render :text => resource.errors.full_messages.to_json }
    end
  end

  def destroy
    if resource.destroy
      flash[:success] = t("destroyed_style")
      record_activity("destroyed_style", resource)
    else
      flash[:error] = t("destroyed_style_error")
    end
    
    respond_with(:site_admin, resource, location: site_admin_styles_path)
  end

  def follow
    resource = Style.find params[:id]
    @style = current_site.styles.new(style_id: resource.id)
    if @style.save
      flash[:success] = t("successfully_created")
    else
      flash[:error] = t("error_creating_object")
    end
    redirect_to site_admin_styles_path(others: true)
  end

  def copy
    resource = Style.find params[:id]
    status = resource.site == current_site ? 
      resource.copy! : 
      current_site.styles.new(name: resource.name, css: resource.css).save
    if status
      flash[:success] = t("successfully_created")
    else
      flash[:error] = t("error_creating_object")
    end
    redirect_to site_admin_styles_path
  end
  
  def sort
    @ch_pos = current_site.own_styles.find(params[:id_moved], :readonly => false)
    increment = 1
    #Caso foi movido para o fim da lista ou o fim de uma pagina(quando paginado)
    p params
    if(params[:id_after] == '0')
      @before = current_site.own_styles.find(params[:id_before])
      condition = "position < #{@ch_pos.position} AND position >= #{@before.position}"
      new_pos = @before.position
    else
      @after = current_site.own_styles.find(params[:id_after])
      #Caso foi movido de cima pra baixo
      if(@ch_pos.position > @after.position)
        condition = "position < #{@ch_pos.position} AND position > #{@after.position}"
        new_pos = @after.position+1
        #Caso foi movido de baixo pra cima
      else
        increment = -1
        condition = "position > #{@ch_pos.position} AND position <= #{@after.position}"
        new_pos = @after.position
      end
    end
    current_site.own_styles.where(condition).update_all("position = position + (#{increment})")
    @ch_pos.update_attribute(:position, new_pos)
    render :nothing => true
  end

  private
  
  # override method from concern to work with relation
  def resource
    get_resource_ivar || set_resource_ivar(current_site.styles.find(params[:id]))
  end

  def after_toggle_path
    site_admin_styles_path
  end
end