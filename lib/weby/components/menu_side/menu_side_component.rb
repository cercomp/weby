class MenuSideComponent < Component
  initialize_component :menu_id

  validates :menu_id, :presence => true
end
