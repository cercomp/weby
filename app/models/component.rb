class Component < ActiveRecord::Base
  extend Weby::ComponentInstance

  belongs_to :site

  # TODO validar também se a área é válida quanto ao layout
  # ex: Um componente pode existe na área X em um layout, mas em outro
  # layout essa área pode não existir
  validates :name, :place_holder, presence: true

  before_save :prepare_variables
  before_update :fix_position
  after_destroy :remove_children, if: proc { name == 'components_group' }

  def default_alias
    ''
  end

  def self.import(attrs, options = {})
    return attrs.each { |attr| import attr, options } if attrs.is_a? Array

    attrs = attrs.dup
    attrs = attrs['component'] if attrs.key? 'component'
    id = attrs['id']
    attrs.except!('id', 'created_at', 'updated_at', 'site_id', 'type')

    settings = eval(attrs['settings'])
    if settings[:body]
      body = settings[:body]
      body["pt-BR"].gsub!(/\/up\/[0-9]+/) {|x| "/up/#{options[:site_id]}"} if body["pt-BR"]
      body["en"].gsub!(/\/up\/[0-9]+/) {|x| "/up/#{options[:site_id]}"} if body["en"]
      settings[:body] = body
      attrs['settings'] = settings.to_s
    end

    settings = eval(attrs['settings'])
    if settings[:repository_id]
      repository = settings[:repository_id]
      if repository.is_a? Hash
        repository["pt-BR"] = Import::Application::CONVAR["repository"]["#{repository["pt-BR"]}"]
        repository["en"] = Import::Application::CONVAR["repository"]["#{repository["en"]}"]
      else
        repository = Import::Application::CONVAR["repository"][repository]
      end
      settings[:repository_id] = repository
      attrs['settings'] = settings.to_s
    end

    settings = eval(attrs['settings'])
    if settings[:photo_ids]
      photos = settings[:photo_ids]
      photos.each_with_index do |photo, index|
        photos[index] = Import::Application::CONVAR["repository"]["#{photo}"]
      end
      settings[:photo_ids] = photos
      attrs['settings'] = settings.to_s
    end

    settings = eval(attrs['settings'])
    if settings[:menu_id]
      settings[:menu_id] = Import::Application::CONVAR["menu"][settings[:menu_id]]
      attrs['settings'] = settings.to_s
    end

    attrs['place_holder'] = options[:place_holder] if options[:place_holder]
    components_children = attrs.delete('children')

    component = self.create!(attrs)
    if component.persisted?
      components_children.each do |child|
        import child, place_holder: component.id, site_id: component.site_id
      end
    end
  end

  def serializable_hash(options = {})
    hash = super options
    hash[:children] = site.components.where(place_holder: id.to_s).map { |c| c.serializable_hash(options) }
    hash
  end

  protected

  def settings_map
    @settings_map = settings ? eval(settings) : {} if @settings_map.nil?
    @settings_map
  end

  def self.update_positions(positions, place_holder)
    positions.to_a.each_with_index do |comp_id, idx|
      attr = { position: idx + 1 }
      attr[:place_holder] = place_holder if place_holder.present?
      Component.find(comp_id).update(attr)
    end
  end

  private

  def prepare_variables
    self.publish = true if publish.nil?
    self.settings = settings_map.to_s
    self.position = Component.maximum('position', conditions: ['site_id = ? AND place_holder = ?', site_id, place_holder]).to_i + 1 if position.blank?
  end

  def remove_children
    position = self.position
    positions = site.components.where(place_holder: place_holder).order('position asc').map { |comp| comp.id }
    Component.where(place_holder: id.to_s).order('position asc').each do |component|
      component.update(place_holder: place_holder)
      positions.insert(position - 1, component.id)
      position += 1
    end
    Component.update_positions positions, place_holder
  end

  def fix_position
    if place_holder_changed? && !position_changed?
      self.position = site.components.maximum(:position, conditions: { place_holder: place_holder }).to_i + 1
    end
  end
end
