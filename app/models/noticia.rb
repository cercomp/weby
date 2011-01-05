class Noticia < Page
  validates_presence_of :title
  validates_presence_of :source
end
