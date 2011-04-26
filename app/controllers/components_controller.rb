class ComponentsController < ApplicationController
  layout :choose_layout
  before_filter :require_user, :check_authorization
  
  helper_method :sort_column
  
  def index
    @components = Component.order(sort_column + ' ' + sort_direction).
      page(params[:page]).per(params[:per_page])

    unless @components
      flash.now[:warning] = (t"none_param", :param => t("component.one"))
    end
  end
  
  def new
    @component = Component.new
  end
  
  def show
    @component = Component.find(params[:id])
  end
  
  def edit
    @component = Component.find(params[:id])
  end
  
  def create
    @component = Component.new(params[:component])
    if @component.save
      redirect_to [@site, @component], :notice => t('successfully_created')
    else
      respond_with [@site, @component]
    end
  end
  
  def update
    @component = Component.find(params[:id])
    if @component.update_attributes(params[:component])
      redirect_to [@site, @component], :notice => t('successfully_updated')
    else
      redirect_to :back
    end
  end
  
  def destroy
    @component = Component.find(params[:id])
    @component.destroy
    
    redirect_to site_components_url
  end
  
  private
  def sort_column
    Component.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end
end
