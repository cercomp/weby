Paperclip.interpolates :site_id do |attachment, _style|
  attachment.instance.site_id
end
Paperclip.options[:whiny] = (ENV['PAPERCLIP_WHINY'].to_s == 'true')
