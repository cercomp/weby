class Repository < ActiveRecord::Base
  has_many :page, 
    foreign_key: 'repository_id'

  belongs_to :site
  has_one :banner

  has_many :pages_repositories
  has_many :pages, :through => :pages_repositories

  scope :description_or_filename, proc {|text|
    text = text.try(:downcase)
    where [ "(LOWER(description) LIKE :text OR LOWER(archive_file_name) LIKE :text)",
            { :text => "%#{text}%" } ] 
  }

  scope :content_file, proc { |content_file|
    if content_file.is_a?(Array)
      # TODO: Esse código funcionará exclusivamente para o Postgresql
      # TODO: Corrigir para funcionar independente do banco de dados.
      content_file.map! {|content| "%#{content}%"}
      where ["archive_content_type SIMILAR TO :values",
             {values: "%(#{content_file.join('|')})%"}
      ]
    else
      archive_content_file(content_file)
    end
  }

  scope :archive_content_file, proc { |content_file|
    where [ "LOWER(archive_content_type) LIKE :content_file",
            { :content_file => "%#{content_file.try(:downcase)}%" } ]
  }

  validates_presence_of :description

  STYLES = {
    mini: "95x70",
    little: "190x140",
    medium: "400x300",
    thumb: "160x160^",
    original: "original"
  }

  has_attached_file :archive,
    styles: STYLES,
    url: "/uploads/:site_id/:style_:basename.:extension",
    convert_options: {
      mini: "-quality 90 -strip",
      little: "-quality 90 -strip",
      medium: "-quality 80 -strip",
      thumb: "-quality 90 -strip -crop \"160x160+0+0\" +repage",
      original: "-quality 80 -strip"}

  validates_attachment_presence :archive,
    :message => I18n.t('activerecord.errors.messages.attachment_presence'), :on => :create

  before_post_process :image?, :normalize_file_name

  # Metodo para incluir a url do arquivo no json
  def archive_url(format = :original)
    self.archive.url(format) 
  end

  alias :as_json_bkp :as_json

  # json alterado para enviar os dados mínimos
  def as_json(options = {})
    self.as_json_bkp only: [:id,
                            :archive_file_name,
                            :description,
                            :archive_content_type],
                            methods: :archive_url
  end

  def image?
    archive_content_type.include?("image") and not archive_content_type.include?("svg")
  end

  def flash?
    archive_content_type.include?("flash") or archive_content_type.include?("shockwave")
  end

  # Remoção de caracteres que causava erro no paperclip
  # TODO: Rever uma melhor implementação
  def normalize_file_name
    archive.instance_write(:file_name, CGI.unescape(archive.original_filename))
  end

  validates :archive_file_name, uniqueness: {:scope => :site_id, :message => I18n.t("file_already_exists")}

  # Reprocessamento de imagens para (re)gerar os thumbnails quando necessário
  def reprocess
    archive.reprocess! if need_reprocess?
  rescue Errno::ENOENT
  end

  private
  def need_reprocess?
    image? and not has_all_formats?
  end

  def has_all_formats?
    STYLES.each_key do |format|
      return false unless exists_archive?(format)
    end 

    true
  end

  def exists_archive?(format=nil)
    FileTest.exist?(archive.path(format))
  end
  
end
