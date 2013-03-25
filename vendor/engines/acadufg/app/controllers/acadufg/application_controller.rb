module Acadufg
  class ApplicationController < ::ApplicationController
  
  protected
    def make_request endpoint, parameters={}
      # Acessando serviço REST que retorna JSON]
      url = CONNECTION[endpoint].gsub(/\%(\w+)\%/){|match| parameters[$1.to_sym]}

      @uri = URI.parse(url)
      pem = File.read(Acadufg::Engine.root.join(CONNECTION["keys_folder"],CONNECTION["pem"].to_s))

      @http = Net::HTTP.new(@uri.host, @uri.port)
      @http.use_ssl = true
      @http.ca_file = Acadufg::Engine.root.join(CONNECTION["keys_folder"],CONNECTION["ca_file"]).to_s

      @http.cert = OpenSSL::X509::Certificate.new(pem)
      @http.key = OpenSSL::PKey::RSA.new(pem)
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      @response_text = @http.request(Net::HTTP::Get.new(@uri.request_uri)).body.force_encoding('UTF-8')
    end
  end
end
