class News < Page
  validates_presence_of :title, :source, :author_id
end
