class News < Page
  default_scope :order => 'updated_at DESC'
  validates_presence_of :title, :source, :author_id
end
