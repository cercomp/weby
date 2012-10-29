class MenuComponent < Component
  component_settings :menu_id, :dropdown

  validates :menu_id, presence: true

  alias :_dropdown :dropdown
  def dropdown
    _dropdown.blank? ? false : _dropdown == "1"
  end

  def default_alias
    menu = Menu.find self.menu_id rescue nil
    menu ? menu.name : ""
  end
end
