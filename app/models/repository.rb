class Repository < ActiveRecord::Base
  default_scope :order => 'updated_at DESC'

  def self.search(search, page, type, per_page, order = 'id DESC')
    paginate :per_page => per_page, :page => page,
        :conditions => ['archive_content_type LIKE ? AND description like ?', "%#{type}%", "%#{search}%"],
        :order => order
  end
  belongs_to :site

	has_one :page
	has_one :banner
	
  has_many :pages_repositories
  has_many :pages, :through => :pages_repositories

  validates_presence_of :description
  has_attached_file :archive, :styles => { :mini => "95x70", :little =>"190x140", :medium => "400x300", :original => "" }, :url => "/uploads/:site_id/:style_:basename.:extension"
  validates_attachment_presence :archive, :message => I18n.t('activerecord.errors.messages.attachment_presence'), :on => :create
  #validates_attachment_content_type :mp3, :content_type => [ "image/bmp", "image/x-png", "image/pjpeg", "image/jpg", "image/jpeg", "image/png", "image/gif" ] 
end
