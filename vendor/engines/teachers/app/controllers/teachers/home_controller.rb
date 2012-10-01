require_dependency "teachers/application_controller"

module Teachers
  class HomeController < ApplicationController
    layout :choose_layout

    def index
    end
  end
end
