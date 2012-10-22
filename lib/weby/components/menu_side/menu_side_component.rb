class MenuSideComponent < Component
  component_settings :menu_id

  validates :menu_id, presence: true

  def default_alias
    menu = Menu.find self.menu_id rescue nil
    menu ? menu.name : ""
  end
end
