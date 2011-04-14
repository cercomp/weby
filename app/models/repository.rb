class Repository < ActiveRecord::Base
  default_scope :order => 'updated_at DESC'

  belongs_to :site

	has_one :page
	has_one :banner
	
  has_many :pages_repositories
  has_many :pages, :through => :pages_repositories

  scope :site_and_content_file, lambda { |site, content_file|
    where(["site_id = ? AND archive_content_type LIKE ?",
           site, "#{content_file}%"])
  }

  validates_presence_of :description
  has_attached_file :archive, :styles => { :mini => "95x70", :little =>"190x140", :medium => "400x300", :original => "" }, :url => "/uploads/:site_id/:style_:basename.:extension"
  validates_attachment_presence :archive, :message => I18n.t('activerecord.errors.messages.attachment_presence'), :on => :create
  #validates_attachment_content_type :mp3, :content_type => [ "image/bmp", "image/x-png", "image/pjpeg", "image/jpg", "image/jpeg", "image/png", "image/gif" ] 
end
