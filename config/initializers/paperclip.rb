Paperclip.interpolates :site_id do |attachment, _style|
  if attachment.instance.respond_to?(:site_id)
    attachment.instance.site_id
  elsif attachment.instance.respond_to?(:parent)
    attachment.instance.parent.site_id
  end
end
Paperclip.interpolates :album_id do |attachment, _style|
  attachment.instance.try(:album_id) || '_'
end
Paperclip.options[:whiny] = (ENV['PAPERCLIP_WHINY'].to_s == 'true')

Paperclip.options[:content_type_mappings] = {
  pem: "text/plain",
  cer: "text/plain",
  crt: "text/plain"
}