class Page < ActiveRecord::Base
  self.inheritance_column = nil

  weby_content_i18n :title, :summary, :text, required: :title

  EVENT_TYPES = %w[regional national international]

  acts_as_taggable_on :categories

  scope :published, where(publish: true)

  scope :news, where(type: 'News')
  scope :events, where(type: 'Event')

  scope :front, where(front: true)

  scope :valid, where("date_begin_at <= :time AND ( date_end_at is NULL OR date_end_at > :time)",
                      { time: Time.now }).published

  scope :search, lambda { |params|
    includes(:author, :categories, :i18ns, :locales).
      where([%{ LOWER(page_i18ns.title) LIKE :params OR
                LOWER(page_i18ns.summary) LIKE :params OR
                LOWER(page_i18ns.text) LIKE :params OR
                LOWER(users.first_name) LIKE :params OR
                LOWER(pages.type) LIKE :params OR
                LOWER(tags.name) LIKE :params},
            { params: "%#{params.try(:downcase)}%" }])
  }

  def event?
    type == 'Event'
  end

  validates :position,
    presence: true,
    if: proc { |page| page.front? }

  validates :type,
    presence: true,
    inclusion: %w[News Event]

  validates :kind,
    inclusion: EVENT_TYPES,
    allow_nil: true,
    allow_blank: true

  validates :date_begin_at, 
    presence: true

  validates :local,
    presence: { if: proc { self.type == 'Event' } }

  belongs_to :owner,
    class_name: "Site",
    foreign_key: "site_id"
  validates :site_id,
    presence: true

  belongs_to :author,
    class_name: "User"
  validates :author_id,
    presence: true

  belongs_to :image,
    class_name: 'Repository',
    foreign_key: 'repository_id'
  validate :should_be_image
  validate :should_be_own_image

  def should_be_image
    return unless have_image?
    error_message = I18n.t("should_be_image")
    errors.add(:image, error_message) unless image?
  end
  private :should_be_image

  def image?
    image.archive_content_type =~ /image/
  end
  private :image?

  def should_be_own_image
    return unless have_image?
    error_message = I18n.t("should_be_own_image")
    errors.add(:image, error_message) unless own_image?
  end
  private :should_be_own_image

  def own_image?
    image.site_id == owner.id
  end
  private :own_image?

  def have_image?
    not image.blank?
  end
  private :have_image?

  def image=(file)
    return self.repository_id = file.id if file.is_a?(Repository)

    self.repository_id = file
  end

  has_many :menu_items,
    as: :target,
    dependent: :nullify

  has_many :banners,
    dependent: :nullify

  has_many :pages_repositories
  has_many :related_files, through: :pages_repositories, source: :repository
  validate :should_be_own_files

  def should_be_own_files
    error_message = I18n.t("should_be_own_files")
    errors.add(:related_files, error_message) unless own_files?
  end
  private :should_be_own_image

  def own_files?
    related_files.each do |file|
      return false if file.site_id != owner.id
    end
    return true
  end
  private :own_files?

end
