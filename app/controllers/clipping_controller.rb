class ClippingController < ApplicationController
  layout "clipping"
  def index    

    @page = Page.front.published.available.clipping.search(params[:search], 1)
    
  end

  def show
  end
end
