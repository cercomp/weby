class MenuSideComponent < Component
  component_settings :menu_id

  validates :menu_id, presence: true
end
