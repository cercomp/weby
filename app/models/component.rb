class Component < ActiveRecord::Base
  # TODO criar migrate para mudar o nome da coluna
  self.table_name = 'site_components'

  extend Weby::ComponentInstance

  before_save :prepare_variables

  belongs_to :site

  # TODO validar também se a posição é válida quanto ao layout
  # ex: Um componente pode existe na posição X em um layout, mas em outro
  # layout essa posição pode não existir
  validates :place_holder, :presence => true

  scope :by_setting, lambda { |setting, value|
    where("settings LIKE '%:#{setting} => \"#{value}\"%'")
  }

protected
  def settings_map
    @settings_map = self.settings ? eval(self.settings) : {} if @settings_map.nil?
    @settings_map
  end

private
  def prepare_variables
    self.publish ||= true
    self.settings = settings_map.to_s
  end
end
