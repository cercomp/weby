module Acadufg::Admin
  class AcadufgController < Acadufg::ApplicationController
    before_filter :require_user
    before_filter :check_authorization
    
    respond_to :html, :js

    def index
    end
  end
end
