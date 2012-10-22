# FIXME mudar o atributo "page" para "page_id" para simular 
# (ou implementar) o comportamento do belongs_to

class NewsAsHomeComponent < Component
  component_settings :page

  validates :page, presence: true

  alias :page_id :page
  def page
    Page.find(self.page_id) rescue nil
  end

  def default_alias
    page = Page.find self.page_id rescue nil
    page ? page.title : ""
  end

end
