# Notícia como página inicial
# FIXME mudar o atributo "page" para "page_id" para simular 
# (ou implementar) o comportamento do belongs_to
class NewsAsHomeComponent < Component
  initialize_component :page

  validates :page, :presence => true

  alias :page_id :page
  def page
    Page.find(self.page_id) rescue nil
  end
end
