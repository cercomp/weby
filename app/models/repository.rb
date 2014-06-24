class Repository < ActiveRecord::Base
  include Trashable

  attr_accessor :x, :y, :w, :h


 STYLES = {
    i: "95x70",
    l: "190x140",
    m: "400x300",
    t: "160x160^",
    o: "original"
  }

  belongs_to :site

  has_many :page, foreign_key: 'repository_id'
  has_many :banners
  has_many :sites, foreign_key: 'top_banner_id'
  has_many :pages_repositories, dependent: :destroy
  has_many :pages, through: :pages_repositories
  has_many :page_image, class_name: 'Page', dependent: :nullify

  has_attached_file :archive,
    styles: STYLES,
    original_style: :o,
    url: "/uploads/:site_id/:style/:basename.:extension",
    convert_options: {
      i: "-quality 90 -strip",
      l: "-quality 90 -strip",
      m: "-quality 80 -strip",
      t: "-crop 160x160+0+0 +repage -quality 90 -strip",
      o: "-quality 80 -strip",
      processors: [:cropper] }

  validates :description, presence: true

  validates_attachment_presence :archive,
                                message: I18n.t('activerecord.errors.messages.attachment_presence'),
                                on: :create

  do_not_validate_attachment_file_type :archive

  scope :description_or_filename, ->(text) {
    text = text.try(:downcase)

    where(["LOWER(description) LIKE :text OR
            LOWER(archive_file_name) LIKE :text", { text: "%#{text}%" }])
  }

  scope :content_file, ->(contents) {
    if contents.is_a?(Array)
      contents = contents.map { |content| "%#{content.gsub('+', '\\\\+')}%" }
      where('archive_content_type SIMILAR TO :values',
            values: "%(#{contents.join('|')})%")
    else
      archive_content_file(contents)
    end
  }

  scope :archive_content_file, ->(content_file) {
    where(['LOWER(archive_content_type) LIKE :content_file',
           { content_file: "%#{content_file.try(:downcase)}%" }])
  }

  before_post_process :image?, :normalize_file_name

  def will_crop?
    !x.blank? && !y.blank? && w.to_i > 0 && h.to_i > 0
  end
#  after_post_process do
#    self.archive_fingerprint = Digest::MD5.file(self.archive.path).to_s
#    archive.instance_write(:file_name, CGI.unescape(archive.original_filename))
#  end

  before_save :presence_file_name

  # Verificar se o arquivo já existe no repositório
  def presence_fingerprint
    a = Digest::MD5.file(archive.uploaded_file).to_s
    puts a
  end

  # Verificar se existe um arquivo com o mesmo nome
  def presence_file_name
    url = "/uploads/:style/:basename.:extension"
  end

  # Metodo para incluir a url do arquivo no json
  def archive_url(format = :o)
    archive.url(format)
  end

  alias_method :as_json_bkp, :as_json

  # json with the minimum data
  def as_json(_options = {})
    as_json_bkp only: [:id,
                       :archive_file_name,
                       :description,
                       :archive_content_type],
                methods: :archive_url
  end

  def image?
    archive_content_type.include?('image') && !archive_content_type.include?('svg')
  end

  def svg?
    archive_content_type.include?('image') && archive_content_type.include?('svg')
  end

  def flash?
    archive_content_type.include?('flash') || archive_content_type.include?('shockwave')
  end

  # Removing characters in conflict with paperclip
  # TODO: Review thie method
  def normalize_file_name
    archive.instance_write(:file_name, CGI.unescape(archive.original_filename))
  end

  validates :archive_file_name, uniqueness: { scope: :site_id, message: I18n.t('file_already_exists') }

  # Reprocessamento de imagens para (re)gerar os thumbnails quando necessário
  def reprocess
    archive.reprocess! if need_reprocess?
  rescue Errno::ENOENT => e
    File.open(Rails.root.join('log/error.log'), 'a') do |f|
      f.write("=> Erro no reprocess: #{e}\n")
    end
  end

  def as_json(options = {})
    json = super(options)
    json['repository'][:o_path] = self.archive.url(:o)
    json['repository'][:l_path] = self.archive.url(:l)
    json['repository'][:m_path] = self.archive.url(:m)
    json['repository'][:i_path] = self.archive.url(:i)
    json['repository'][:t_path] = self.archive.url(:t)
    json
  end

  def self.import(attrs, options = {})
    return attrs.each { |attr| import attr, options } if attrs.is_a? Array

    attrs = attrs.dup
    attrs = attrs['repository'] if attrs.key? 'repository'

    attrs.except!('id', 'created_at', 'updated_at', 'deleted_at', 'site_id', 'type')

    self.create!(attrs)
  end

  private

  def need_reprocess?
    image? && !has_all_formats?
  end

  def has_all_formats?
    STYLES.each_key do |format|
      return false unless exists_archive?(format)
    end
    true
  end

  def exists_archive?(format = nil)
    FileTest.exist?(archive.path(format))
  end
end
