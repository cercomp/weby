module PagesHelper

  def locale_with_name(locale)
    locale = Locale.find_by_name(locale)
    raw %{
      #{image_tag("flags/24/#{locale.flag}", :title=>t(locale.name))} 
      #{t(locale.name)}
    }
  end
end
