class Event < Page
  validates_presence_of :title, :local, :author_id
end
