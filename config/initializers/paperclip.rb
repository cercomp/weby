Paperclip.interpolates :site_id do |attachment, _style|
  attachment.instance.site_id
end
Paperclip.options[:whiny] = (ENV['PAPERCLIP_WHINY'].to_s == 'true')

Paperclip.options[:content_type_mappings] = {
  pem: "text/plain",
  cer: "text/plain",
  crt: "text/plain"
}