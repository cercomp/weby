class Sites::ComponentsController < ApplicationController
  layout false #:choose_layout
  respond_to :html, :xml, :js

  def show
    @component = Weby::Components.factory(current_site.components.find(params[:id]))
  end
end
