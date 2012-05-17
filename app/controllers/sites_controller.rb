class SitesController < ApplicationController
  layout :choose_layout, only: :show
  
  before_filter :require_user, :only => :admin
  
  respond_to :html, :xml, :js

  helper_method :sort_column

  def index
    params[:per_page] ||= Setting.get(:per_page_default)

    @sites = Site.name_or_description_like(params[:search]).
      except(:order).
      order(sort_column + " " + sort_direction).
      page(params[:page]).
      per(params[:per_page])
    flash[:warning] = (t"none_param", :param => t("page.one")) unless @sites
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

  def admin
    render layout: false
  end

  private
  def sort_column
    Site.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end
end
