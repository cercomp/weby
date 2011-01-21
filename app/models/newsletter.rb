class Newsletter < Page
  validates_presence_of :url, :title, :author_id
end
