class ClippingController < ApplicationController
  layout 'weby_pages'

  def index
    @pages = Page.front.published.available.clipping.search(params[:search], 1)
  end
end
