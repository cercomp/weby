class ClippingController < ApplicationController
  layout 'weby_pages'

  helper_method :sort_column

  def index
    @pages = Page.front.published.available.clipping.search(params[:search], 1)
  end

  def condensed

    @pages = Page.front.published.available.clipping.search(params[:search], 1)

    params[:per_page] ||= current_settings[:per_page_default]
    @sites = Site.name_or_description_like(params[:search]).
      except(:order).
      order(sort_column + " " + sort_direction).
      page(params[:page]).
      per(params[:per_page])
    flash[:warning] = (t"none_page") unless @sites

    @my_sites = current_user ? current_user.sites : []

  end

  private
  def sort_column
    Site.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end

end
