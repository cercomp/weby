class MenuSideComponent < SiteComponent
  initialize_component :category

  validates :category, :presence => true
end
