class Repository < ApplicationRecord
  include Trashable

  attr_accessor :x, :y, :w, :h

  belongs_to :site
  belongs_to :user, optional: true # opcional para comportar os arquivos existentes

  has_many :sites, foreign_key: 'top_banner_id', dependent: :nullify
  has_many :posts_repositories, dependent: :destroy
  has_many :posts, through: :posts_repositories
  # Extensions relations
  has_many :news, class_name: 'Journal::News', dependent: :nullify
  has_many :banners, class_name: 'Sticker::Banner', dependent: :nullify
  has_many :events, class_name: 'Calendar::Event', dependent: :nullify

  has_attached_file :archive,
    styles: {
      o: "original",
      t: "160x160#",
      i: "95x70",
      l: "190x140",
      m: "400x300"
    },
    original_style: :o,
    path: proc {
      Rails.env.production? ?
        '/up/:site_id/:style/:basename.:extension'
      : ':rails_root/public:url'
    },
    url: '/up/:site_id/:style/:basename.:extension',
    convert_options: {
      o: "-quality 90",
      t: "-quality 80 -strip", #-crop 160x160+0+0 +repage
      i: "-quality 90 -strip",
      l: "-quality 90 -strip",
      m: "-quality 80 -strip"
    }
    #,processors: [:cropper]


  validates :description, presence: true

  validates_attachment_presence :archive,
                                message: I18n.t('activerecord.errors.messages.attachment_presence'),
                                on: :create

  do_not_validate_attachment_file_type :archive

  scope :description_or_filename, ->(text) {
    text = text.try(:downcase)

    where(["LOWER(repositories.description) LIKE :text OR
            LOWER(repositories.archive_file_name) LIKE :text", { text: "%#{text}%" }])
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

  def audio?
    archive_content_type.include?('audio')
  end

  # Removing characters in conflict with paperclip
  # TODO: Review thie method
  def normalize_file_name
    archive.instance_write(:file_name, CGI.unescape(archive.original_filename))
  end

  validates :archive_file_name, uniqueness: { scope: :site_id, message: I18n.t('file_already_exists') }

  # Reprocessamento de imagens para (re)gerar os thumbnails quando necessário
  def reprocess
    archive.reprocess! #if need_reprocess?
  # rescue Errno::ENOENT => e
  #   File.open(Rails.root.join('log/error.log'), 'a') do |f|
  #     f.write("=> Erro no reprocess: #{e}\n")
  #   end
  end

  def increment_filename
    idx = 1
    if ( m = self.archive_file_name.match(/\-(\d{1,4})\.\w{3,4}$/) )
      idx = m[1].to_i + 1
    else
      self.archive_file_name.gsub!(/\.(\w{3,4})$/, "-#{idx}.\\1")
    end

    loop do
      self.archive_file_name.gsub!(/\-(\d{1,4})\.(\w{3,4})$/, "-#{idx}.\\2")
      idx += 1
      break if !Repository.where(site_id: site_id).exists?(archive_file_name: self.archive_file_name)
    end
  end

  def as_json(options = {})
    json = super(options)
    json[:file_url] = self.archive.path(:o)
    json[:original_path] = self.archive.url(:o)
    json[:little_path] = self.archive.url(:l)
    json[:medium_path] = self.archive.url(:m)
    json[:mini_path] = self.archive.url(:i)
    json[:thumb_path] = self.archive.url(:t)
    json
  end

  def self.import(attrs, options = {})
    return attrs.each { |attr| import attr, options } if attrs.is_a? Array

    attrs = attrs.dup
    attrs = attrs['repository'] if attrs.key? 'repository'
    id = attrs['id']
    attrs.except!('id', 'created_at', 'updated_at', 'deleted_at', 'site_id', 'type', '@type')
    repo = self.find_by(archive_file_name: attrs['archive_file_name'], site_id: options[:site_id]) || self.create!(attrs)
    if repo.persisted?
      Import::Application::CONVAR["repository"]["#{id}"] ||= "#{repo.id}"
    end
  end

  private

  def need_reprocess?
    image? && !has_all_formats?
  end

  def has_all_formats? # only works for local storage
    archive.options[:styles].each_key do |format|
      return false unless exists_archive?(format)
    end
    true
  end

  def exists_archive?(format = nil)
    FileTest.exist?(archive.path(format))
  end
end
