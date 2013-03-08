module Acadufg::Admin
  class AcadufgController < Acadufg::ApplicationController
    before_filter :require_user
    before_filter :check_authorization
    
    respond_to :html, :js

    def index
      @Acadsetting = Acadufg::Setting.find(:first, :conditions => ["site_id = ?", current_site])
      @Acadsetting = @Acadsetting || Acadufg::Setting.new
    end
  end
end
