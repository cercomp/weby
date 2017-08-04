class MenuComponent < Component
  component_settings :menu_id, :dropdown, :style

  validates :menu_id, presence: true

  alias_method :_dropdown, :dropdown
  def dropdown
    _dropdown.blank? ? false : _dropdown == '1'
  end

  def menu
    Menu.find_by(id: menu_id)
  end

  def default_alias
    menu = Menu.find menu_id rescue nil
    menu ? menu.name : ''
  end

  def menu_styles
    [:menu, :hamburger]
  end
end
