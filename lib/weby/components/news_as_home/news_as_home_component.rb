class NewsAsHomeComponent < Component
  initialize_component :page_id

  validates :page_id, :presence => true

  def page
    Page.find(self.page_id) rescue nil
  end
end
