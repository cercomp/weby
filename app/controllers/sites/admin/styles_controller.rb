class Sites::Admin::StylesController < ApplicationController

  before_filter :require_user
  before_filter :check_authorization
  before_filter :verify_ownership, only: [:edit, :update, :destroy]

  respond_to :html, :xml, :js
  
  helper_method :sort_column, :sort_direction

  def index
    return only_selected_style if params[:style_type]
    @styles = {
      own: own_styles,
      follow: follow_styles,
      other: other_styles
    }    
  end

  def only_selected_style
    @styles = {
      params[:style_type].to_sym => send("#{params[:style_type]}_styles")
    }
  end

  # FIXME: duplicated code
  def own_styles
    styles = current_site.own_styles.scoped.
      order('position desc')

    search(styles, :own) || styles
  end
  private :own_styles

  # FIXME: duplicated code
  def follow_styles
    params[:style_type] = 'follow'
    styles = current_site.follow_styles.scoped.
      order(sort_column + " " + sort_direction).page(params[:page_follow_styles]).per(5)

    search(styles, :follow) || styles
  end
  private :follow_styles

  # FIXME: duplicated code
  def other_styles
    styles = Style.not_followed_by(current_site).
      order(:id).page(params[:page_other_styles]).per(5)

    search(styles, :other) || styles
  end
  private :other_styles

  def search(styles, type)
    if params[:style_type] == type.to_s && params[:style_name]
      styles.by_name(params[:style_name]) if params[:style_type] == type.to_s
    end
  end
  private :search
  
  def sort_column
    params[:sort] || 'styles.name'
  end
  private :sort_column
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  private :sort_direction

  def show
    @style = Style.find(params[:id])
  end

  def new
    @style = Style.new
    @style.publish = true
  end

  def edit
    @style = Style.find(params[:id])
  end

  def create
    @style = Style.new(params[:style])
    @style.position = current_site.own_styles.count + 1
    
    if @style.save
      flash[:success] = t("successfully_created")
      record_activity("created_style", @style)
    end
    respond_with(:site_admin, @style, location:  edit_site_admin_style_path(@style))
  end

  def update
    @style = Style.find(params[:id])

    if @style.update_attributes(params[:style])
      flash[:success] = t("successfully_updated")
      record_activity("updated_style", @style)
    end
    respond_with(:site_admin, @style, location: site_admin_styles_path) do |format|
      format.json{ render :text => @style.errors.full_messages.to_json }
    end
  end

  def destroy
    @style = Style.find(params[:id])

    if @style.destroy
      flash[:success] = t("destroyed_style")
      record_activity("destroyed_style", @style)
    else
      flash[:alert] = t("destroyed_style_error")
    end
    
    respond_with(:site_admin, @style, location: site_admin_styles_path())
  end

  def follow
    @style = Style.find(params[:id])
    current_site.follow_styles << @style
    
    @site_style = @style.sites_styles.where(site_id: current_site.id).first
    @site_style.update_attributes(publish: true)

    redirect_to site_admin_styles_path(others: true)
  end

  def unfollow
    @style = Style.find(params[:id])
    @site_style = @style.sites_styles.where(site_id: current_site.id).first
    @site_style.destroy

    redirect_to site_admin_styles_path(others: true)
  end
  
  # Publish and unpublish style
  def toggle_field
    @style = Style.find(params[:id])
    if params[:field]
      own = @style.owner != current_site
      if own
        @style = @style.sites_styles.where(site_id: current_site.id)[0]
        @style.toggle!(:publish)
      else
        @style.toggle!(:publish)
      end
      flash[:success] = t("successfully_updated")
    else
      flash[:warning] = t("error_updating_object")
    end
    redirect_to site_admin_styles_path(others: own ? "true" : nil)
  end

  def copy
    @style = Style.find(params[:id]).dup
    @style.owner = current_site
    @style.publish = false

    if @style.save
      flash[:success] = t("successfully_created")
    else
      flash[:error] = t("error_creating_object")
    end

    redirect_to site_admin_styles_path()
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
  def verify_ownership
    @style = Style.find(params[:id])

    unless @style.owner == current_site
      flash[:warning] = t("no_permission_to_action")
      redirect_to site_admin_style_url @style
    end
  end
end
