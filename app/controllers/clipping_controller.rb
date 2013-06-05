class ClippingController < ApplicationController
  layout "clipping"
  def index    

    @page = Page.front.published.available.clipping
    
  end

  def show
  end
end
