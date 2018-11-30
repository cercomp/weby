class MenuI18nComponent < Component
  component_settings :dropdown, :template

  alias_method :_dropdown, :dropdown
  def dropdown
    _dropdown.blank? ? false : _dropdown.to_i == 1
  end

  def template_options
    ['flag', 'code']
  end
end
