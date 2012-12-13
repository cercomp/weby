class Component < ActiveRecord::Base
  # TODO criar migrate para mudar o nome da coluna
  self.table_name = 'site_components'

  extend Weby::ComponentInstance

  before_save :prepare_variables

  belongs_to :site

  # TODO validar também se a área é válida quanto ao layout
  # ex: Um componente pode existe na área X em um layout, mas em outro
  # layout essa área pode não existir
  validates :place_holder, presence: true
  validates :name, presence: true

  def default_alias
    ""
  end

  protected
  def settings_map
    @settings_map = self.settings ? eval(self.settings) : {} if @settings_map.nil?
    @settings_map
  end

  private
  def prepare_variables
    self.publish = true if self.publish.nil?
    self.settings = settings_map.to_s
    self.position = Component.maximum('position', :conditions=> ["site_id = ? AND place_holder = ?", self.site_id, self.place_holder]).to_i + 1 if self.position.blank?
  end
end
