class SiteComponent < ActiveRecord::Base
  before_save :prepare_variables

  belongs_to :site

  scope :by_setting, lambda { |setting, value|
    where("settings LIKE '%:#{setting} => \"#{value}\"%'")
  }

  class << self
    def component_name
      # Por padrão todo componente terá o "Component" no fim do nome, então retiramos
      # ex: GovBarComponent.tableize # => gov_bar_component.gsub(...) => gov_bar
      @component_name ||= self.name.tableize.gsub(/_components$/, '')
    end

    def register_settings(*settings)
      settings.each do |setting|
        class_eval <<-METHOD
          default_scope where(:component => self.component_name)
          attr_accessor :#{setting}
        METHOD

        ActionController::Base.view_paths << Rails.root.join('lib', 'weby', 'components', self.component_name, 'views')
        Weby::Application.config.i18n.load_path += Dir[
          Rails.root.join('lib', 'weby', 'components', self.component_name, 'locales', '*.{rb,yml}').to_s
        ]
      end
    end
  end

  def settings_map
    @settings_map = self.settings ? eval(self.settings) : {} if @settings_map.nil?
    @settings_map
  end
  protected :settings_map

  def prepare_variables
    self.publish ||= true
    self.settings = settings_map.to_s
  end
  private :prepare_variables
end
