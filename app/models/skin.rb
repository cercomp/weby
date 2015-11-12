class Skin < ActiveRecord::Base

  belongs_to :site

  has_many :components, dependent: :destroy
  has_many :root_components, ->(obj) { obj.site.theme ? order(:position).where("place_holder !~ '^\\d*$'").where(skin_id: obj.id) : where(nil) }, class_name: 'Component'
  has_many :styles, -> { order('styles.position DESC') }, dependent: :destroy


  def base_theme
    Weby::Themes.theme(theme)
  end

  def layout
    base_theme.layout.merge(attributes[:layout].to_h)
  end

  #def components
  #  base_theme.components.merge(attributes[:components].to_h)
  #end

  def self.import(attrs, options = {})
    return attrs.each { |attr| import attr, options } if attrs.is_a? Array

    attrs = attrs.dup
    attrs = attrs['skin'] if attrs.key? 'skin'

    styles = attrs.delete('styles')
    components = attrs.delete('root_components')

    attrs.except!('id', 'created_at', 'updated_at', 'site_id', '@type', 'type')

    newskin = self.create!(attrs)

    newskin.styles.import(styles)
    newskin.components.import(components, site_id: options[:site_id])
  end

end
