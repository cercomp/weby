class SiteComponent < ActiveRecord::Base
  before_save :prepare_variables

  belongs_to :site

  # TODO validar também se a posição é válida quanto ao layout
  # ex: Um componente pode existe na posição X em um layout, mas em outro
  # layout essa posição pode não existir
  validates :place_holder, :presence => true

  scope :by_setting, lambda { |setting, value|
    where("settings LIKE '%:#{setting} => \"#{value}\"%'")
  }

  class << self

    def initialize_component(*settings)
      class_eval do
        # Por padrão todo componente terá o "Component" no fim do nome, ele será retirado
        # ex: GovBarComponent.tableize # => gov_bar_component.gsub(...) => gov_bar
        @component_name ||= self.name.tableize.gsub(/_components$/, '')

        def component_name
          @component_name
        end
      end

      settings.each do |setting|
        class_eval <<-METHOD
          def #{setting}=(value)
            settings_map[:#{setting}] = value
          end
          
          def #{setting}
            settings_map[:#{setting}]
          end
        METHOD
      end

      default_scope where(:component => @component_name)

      ActionController::Base.view_paths << Rails.root.join('lib', 'weby', 'components', @component_name, 'views')
      Weby::Application.config.i18n.load_path += Dir[
        Rails.root.join('lib', 'weby', 'components', @component_name, 'locales', '*.{rb,yml}').to_s
      ]
    end
  end

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
