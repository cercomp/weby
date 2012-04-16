class NewsAsHomeComponent < Component
  initialize_component :page

  validates :page, :presence => true
end
