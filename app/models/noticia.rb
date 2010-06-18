class Noticia < Pagina
  validates_presence_of :titulo
  validates_presence_of :fonte

end
