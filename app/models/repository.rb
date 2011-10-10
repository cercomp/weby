class Repository < ActiveRecord::Base
  default_scope :order => 'updated_at DESC'

  belongs_to :site
  has_one :page
  has_one :banner

  has_many :pages_repositories
  has_many :pages, :through => :pages_repositories

  scope :description_or_filename, proc {|text|
    text = text.try(:downcase)
    where [ "(LOWER(description) LIKE :text OR LOWER(archive_file_name) LIKE :text)",
            { :text => "%#{text}%" } ] 
  }

  scope :content_file, lambda{ |content_file|
    where [ "LOWER(archive_content_type) LIKE :content_file",
            { :content_file => "%#{content_file.try(:downcase)}%" } ]
  }

  # Para esse escopo deve ser passado o mimetype completo em um array
  # Example:: ["image/png", "application/pdf"]
  scope :multiple_content_file, lambda { |multiple_content_file|
    where(archive_content_type: multiple_content_file) unless multiple_content_file.blank?
  }

  validates_presence_of :description
  has_attached_file :archive,
    :styles => { :mini => "95x70", :little =>"190x140", :medium => "400x300", :original => "" },
    :url => "/uploads/:site_id/:style_:basename.:extension"

  validates_attachment_presence :archive, :message => I18n.t('activerecord.errors.messages.attachment_presence'), :on => :create

  before_post_process :image?, :normalize_file_name

  def image?
    if archive_content_type.include?("svg")
      return false
    else  
      archive_file_namee_content_type.include?("image") 
    end  
  end

  def normalize_file_name
    file_name = (archive.to_s + '_file_name')._file_nameto_sym
    if self.send(file_name)
      self.send(archive).instance_write(:file_name, self.send(attachment_file_name).gsub(/ /,'_'))
    end
  end
end
