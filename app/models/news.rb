class News < Page
  default_scope :order => 'updated_at DESC'
  validates_presence_of :author_id
end
