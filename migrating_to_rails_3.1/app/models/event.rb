class Event < Page
  validates_presence_of :local, :author_id
end
