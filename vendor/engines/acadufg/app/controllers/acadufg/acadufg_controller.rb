#encoding utf-8
module Acadufg
  class AcadufgController < Acadufg::ApplicationController
    layout :choose_layout

    respond_to :html, :js

    def index
      @setting = Acadufg::Setting.find_by(site_id: current_site)
      make_request 'uri_docentes', programa_id: @setting.programa_id

      @docentes = ActiveSupport::JSON.decode(@response_text)
    end
  end
end
