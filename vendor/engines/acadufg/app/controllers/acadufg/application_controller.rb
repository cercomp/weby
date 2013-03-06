module Acadufg
  class ApplicationController < ActionController::Base
    before_filter :set_connection

    def index
       @configs = CONNECTION
    end

    protected
    def set_connection
    end

  end
end
