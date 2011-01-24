class Repository < ActiveRecord::Base
  def self.search(search, page)
    paginate :per_page => 4, :page => page, :conditions => ['description like ?', "%#{search}%"], :order => 'id DESC'
  end
  belongs_to :site

  has_attached_file :archive, :url => "/uploads/:site_id/:style_:basename.:extension"
  validates_presence_of :description
  validates_attachment_presence :archive, :message => I18n.t('activerecord.errors.messages.attachment_presence')

  #validates_attachment_content_type :mp3, :content_type => [ "image/bmp", "image/x-png", "image/pjpeg", "image/jpg", "image/jpeg", "image/png", "image/gif" ] 
end
