module Acadufg 
  class AcadufgController < Acadufg::ApplicationController
    layout :choose_layout
    before_filter :set_connection
    
    respond_to :html, :js

    def index
      @configs = CONNECTION
    end

    protected
    def set_connection
      # TODO
    end
  end
end
