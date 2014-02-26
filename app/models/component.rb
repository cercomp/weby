class Component < ActiveRecord::Base
  # TODO criar migrate para mudar o nome da coluna
  self.table_name = 'site_components'

  extend Weby::ComponentInstance

  before_save :prepare_variables
  before_update :fix_position
  after_destroy :remove_children, if: Proc.new{ self.name == "components_group" }
  #has_many :children, class_name: 'Component', foreign_key: 'place_holder', conditions: "name='components_group'"

  belongs_to :site

  # TODO validar também se a área é válida quanto ao layout
  # ex: Um componente pode existe na área X em um layout, mas em outro
  # layout essa área pode não existir
  validates :place_holder, presence: true
  validates :alias, presence: true
  validates :name, presence: true

  def default_alias
    ""
  end

  def self.import attrs, options={}
    return attrs.each{|attr| self.import attr } if attrs.is_a? Array

    attrs = attrs.dup
    attrs = attrs['component'] if attrs.has_key? 'component'

    attrs.except!('id', 'created_at', 'updated_at', 'site_id', 'type')
    attrs["place_holder"] = options[:place_holder] if options[:place_holder]
    components_children = attrs.delete('children')

    component = self.create!(attrs)
    if component.persisted?
      components_children.each do |child|
        self.import child, place_holder: component.id
      end
    end
  end

  def serializable_hash options={}
    hash = super options
    hash[:children] = self.site.components.where(place_holder: self.id.to_s).map{|c| c.serializable_hash(options)}
    hash
  end

  protected

  def settings_map
    @settings_map = self.settings ? eval(self.settings) : {} if @settings_map.nil?
    @settings_map
  end

  def self.update_positions positions, place_holder
    positions.to_a.each_with_index do |comp_id, idx|
      attr = {position: idx+1}
      attr[:place_holder] = place_holder if place_holder.present?
      Component.find(comp_id).update_attributes(attr)
    end
  end

  private
  def prepare_variables
    self.publish = true if self.publish.nil?
    self.settings = settings_map.to_s
    self.position = Component.maximum('position', :conditions=> ["site_id = ? AND place_holder = ?", self.site_id, self.place_holder]).to_i + 1 if self.position.blank?
  end

  def remove_children
    position = self.position
    positions = self.site.components.where(place_holder: self.place_holder).order('position asc').map{|comp| comp.id }
    Component.where(place_holder: self.id.to_s).order('position asc').each do |component|
      component.update_attributes(place_holder: self.place_holder)
      positions.insert(position-1, component.id)
      position += 1
    end
    Component.update_positions positions, self.place_holder
  end

  def fix_position
    if place_holder_changed? && !position_changed?
      self.position = site.components.maximum(:position, conditions: {place_holder: place_holder}).to_i + 1
    end
  end
end
