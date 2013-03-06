require "net/https"
require "uri"

# Acessando serviço REST que retorna JSON
uri = URI.parse("https://200.137.217.204/barramento/services/rest/docentes")
pem = File.read("WEBYc.pem")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.ca_file = 'ca.pem'
http.cert = OpenSSL::X509::Certificate.new(pem)
http.key = OpenSSL::PKey::RSA.new(pem)
http.verify_mode = OpenSSL::SSL::VERIFY_PEER

request = Net::HTTP::Get.new(uri.request_uri)
response = http.request(request).body

#puts  http.methods

puts response
