module LocalesHelper
  def flag(locale, size = '24', options = {})
    options.reverse_merge!({title: t(locale.name)})
    
    image_tag("flags/#{size}/#{locale.flag}", options)
  end
end