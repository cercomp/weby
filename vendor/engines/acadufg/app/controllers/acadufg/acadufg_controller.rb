module Acadufg 
  class AcadufgController < Acadufg::ApplicationController
    layout :choose_layout
    before_filter :set_connection
    
    respond_to :html, :js

    #TODO: read http://ruby-doc.org/stdlib-2.0/libdoc/net/http/rdoc/Net/HTTP.html#method-i-request
    def index
      request = Net::HTTP::Get.new(@uri.request_uri)
      @response = @http.request(request)

    end

    protected
    def set_connection
      # Acessando serviço REST que retorna JSON
      @uri = URI.parse(CONNECTION["uri"])
      @pem = File.read(Acadufg::Engine.root.join(CONNECTION["keys_folder"],CONNECTION["pem"]))
      
      @http = Net::HTTP.new(@uri.host, @uri.port)
      @http.use_ssl = true
      @http.ca_file = Acadufg::Engine.root.join(CONNECTION["keys_folder"],CONNECTION["ca_file"])

      @http.cert = OpenSSL::X509::Certificate.new(@pem)
      @http.key = OpenSSL::PKey::RSA.new(@pem)
      @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end
  end
end
