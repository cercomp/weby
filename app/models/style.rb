class Style < ApplicationRecord
  belongs_to :skin
  belongs_to :style, optional: true
  has_one :site, through: :skin

  has_many :styles, dependent: :restrict_with_error
  has_many :followers, through: :styles, source: :site

  validates :skin, presence: true
  validates :name, presence: true, unless: :style_id
  validates :style_id, uniqueness: { scope: :skin_id }, if: :style_id

  validate :self_relation

  scope :search, ->(term) {
    fields = ['styles.name', 'sites.title', 'sites.name']

    includes(:site)
      .where(fields.map { |field| "lower(#{field}) like :term" }.join(' OR '), term: "%#{term.downcase}%")
      .references(:site) if term
  }

  # returns all styles that are not being followed
  # in follow_styles was used a hack to avoid null return
  scope :not_followed_by, ->(skin) {
    includes(skin: :site)
      .where('styles.id not in (:follow_styles) AND skins.theme = :theme AND skins.site_id <> :site_id AND styles.style_id is null',
             follow_styles: skin.styles.where('style_id is not null').map(&:style_id) << 0,
             site_id: skin.site_id, theme: skin.theme).references(:site)
  }

  scope :own, -> { where('style_id is null') }

  scope :published, -> { where(publish: true) }

  after_create :define_position

  def copy!(to_skin)
    if site == to_skin.site
      return false unless style_id

      update(css: css, name: name, style_id: nil) ? self : false
    else
      return false if style_id

      Style.create!(name: name, css: css, skin: to_skin)
    end
  end

  def original
    style || self
  end

  def css
    style ? style.css : read_attribute(:css)
  end

  def name
    style ? style.name : read_attribute(:name)
  end

  def owner
    style ? style.site : site
  end

  def self.import(attrs, options = {})
    return attrs.each { |attr| import attr, options } if attrs.is_a? Array

    attrs = attrs.dup
    attrs = attrs['style'] if attrs.key? 'style'

    if attrs['style_id'].present?
      follow = Style.unscoped.find_by(id: attrs['style_id'])
      if follow && attrs['name'] == follow.name
        attrs['css'] = nil
        attrs['name'] = nil
      else
        attrs['style_id'] = nil
      end
    end

    attrs.except!('id', 'created_at', 'updated_at', 'skin_id', '@type', 'type')

    self.create!(attrs)
  end

  private

  def self_relation
    if style
      errors[:base] = I18n.t('cant_follow_own_styles') if style.site == site
      errors[:base] = I18n.t('can_only_follow_styles') if style.style
    end
  end

  def define_position
    update(position: skin.styles.maximum(:position) + 1)
  end
end
