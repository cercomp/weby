#encoding utf-8
module Acadufg
  require 'iconv'
  class AcadufgController < Acadufg::ApplicationController
    layout :choose_layout
    before_filter :set_connection
    
    respond_to :html, :js

    #TODO: read http://ruby-doc.org/stdlib-2.0/libdoc/net/http/rdoc/Net/HTTP.html#method-i-request
    def index
      @response = @http.request(Net::HTTP::Get.new(@uri.request_uri)).body
      @reponse =  @response.force_encoding('UTF-8')
    end

    protected
    def set_connection
      # Acessando serviço REST que retorna JSON
      @uri = URI.parse(CONNECTION["uri"])
      @pem = File.read(Acadufg::Engine.root.join(CONNECTION["keys_folder"],CONNECTION["pem"].to_s))
      
      @http = Net::HTTP.new(@uri.host, @uri.port)
      @http.use_ssl = true
      @http.ca_file = Acadufg::Engine.root.join(CONNECTION["keys_folder"],CONNECTION["ca_file"]).to_s

      @http.cert = OpenSSL::X509::Certificate.new(@pem)
      @http.key = OpenSSL::PKey::RSA.new(@pem)
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
  end
end
