class SiteComponent < ActiveRecord::Base
  before_save :prepare_variables

  belongs_to :site

  scope :by_setting, lambda { |setting, value|
    where("settings LIKE '%:#{setting} => \"#{value}\"%'")
  }

  protected
  def settings_map
    @settings_map = self.settings ? eval(self.settings) : {} if @settings_map.nil?
    @settings_map
  end

  class << self
    def component_name(name = nil)
      @component_name ||= !name.nil? ? name.to_s : self.name.tableize
    end

    def register_settings(*settings)
      settings.each do |setting|
        class_eval <<-METHOD
          default_scope where(:component => self.component_name)

          def #{setting}=(value)
            settings_map[:#{setting}] = value
          end
          
          def #{setting}
            settings_map[:#{setting}]
          end
        METHOD
      end
      # TODO criar um components_path lá nas configs
      ActionController::Base.view_paths << Rails.root.join('lib', 'weby', 'components', component_name, 'views')
    end
  end

  private
  def prepare_variables
    self.publish ||= true
    self.settings = settings_map.to_s
  end
end
