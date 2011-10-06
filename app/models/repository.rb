class Repository < ActiveRecord::Base
  default_scope :order => 'updated_at DESC'

  belongs_to :site
  has_one :page
  has_one :banner
	
  has_many :pages_repositories
  has_many :pages, :through => :pages_repositories

  scope :description_or_file_and_content_file, lambda { |text, content_file|
    where( [ "(LOWER(description) LIKE :text OR LOWER(archive_file_name) LIKE :text) AND LOWER(archive_content_type) LIKE :content_file",
           { :text => "%#{text.try(:downcase)}%", :content_file => "#{content_file.try(:downcase)}%" } ] )
  }

  validates_presence_of :description
  has_attached_file :archive, :styles => { :mini => "95x70", :little =>"190x140", :medium => "400x300", :original => "" }, :url => "/uploads/:site_id/:style_:basename.:extension"
  validates_attachment_presence :archive, :message => I18n.t('activerecord.errors.messages.attachment_presence'), :on => :create
  #validates_attachment_content_type :mp3, :content_type => [ "image/bmp", "image/x-png", "image/pjpeg", "image/jpg", "image/jpeg", "image/png", "image/gif" ] 

	before_post_process :image?, :normalize_file_name

	def image?
    if archive_content_type.include?("svg")
      return false
    else  
      archive_content_type.include?("image") 
    end  
  end
  # Remoção de caracteres que causava erro no paperclip
  # TODO: Rever uma melhor implementação
  def normalize_file_name
    archive.instance_write(:file_name, CGI.unescape(archive.original_filename))
  end

end
