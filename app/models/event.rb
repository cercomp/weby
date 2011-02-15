class Event < Page
  default_scope :order => 'updated_at DESC'
  validates_presence_of :title, :local, :author_id
end
