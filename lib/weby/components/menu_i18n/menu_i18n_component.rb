class MenuI18nComponent < Component
  component_settings :dropdown, :template, :use_translator, :extra_langs

  def dropdown?
    dropdown.blank? ? false : dropdown.to_i == 1
  end

  # alias_method :_extra_langs, :extra_langs
  # def extra_langs
  #   _extra_langs.to_a.select{|l| l.present? }
  # end

  def use_translator?
    use_translator.to_i == 1
  end

  def extra_langs_options
    []
  end

  def template_options
    ['flag', 'code', 'flag_name']
  end

  def use_locales(site)
    locales = site.locales.to_a
    # if use_translator? && extra_langs.any?
    #   locales += extra_langs.map{|l| Locale.new(name: l) }
    # end
    locales
  end
end
