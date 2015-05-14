class Skin < ActiveRecord::Base

  belongs_to :site

  has_many :components, dependent: :destroy
  has_many :root_components, ->(site) { site.theme ? order(:position).where("place_holder !~ '^\\d*$'").where(theme: site.theme.name) : where(nil) }, class_name: 'Component'
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

end
