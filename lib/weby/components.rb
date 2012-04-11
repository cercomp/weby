module Weby

  module Components
    
    # Array de componentes disponíveis
    mattr_accessor :available_components

    def self.setup
      yield self
    end

    def self.factory(component)
      # A idéia é pegar um componente definido com a classe "SiteComponent" e passar
      # para a classe filha
      if component.class == SiteComponent
        build = Object::const_get("#{component.component_name.classify}Component").find(component.id)
      else
        ## FIXME verifica se o componente existe
        build = Object::const_get("#{component.classify}Component").new
      end

      return build
    end
    
    ActionView::Helpers::RenderingHelper.module_eval do
      def render_component(component, view = 'show', args = {})
        args[:partial] = "components/#{component.component_name}/#{view.to_s}"
        
        args[:locals] ||= {}
        args[:locals].merge!({ :component => component })

        # Caso a partial não exista, não mostra nada
        render args rescue ''
      end
    end
  end

  module ComponentInstance
    def initialize_component(*settings)

      class_eval do
        # Método estatico para pegar o nome do componente
        def self.component_name
          # Por padrão todo componente terá o "Component" no fim do nome, ele será retirado
          # ex: GovBarComponent.tableize # => gov_bar_component.gsub(...) => gov_bar
          self.name.tableize.gsub(/_components$/, '')
        end

        # Inicializa o nome do componente quando ele é criado
        after_initialize do
          self.component_name = self.class.component_name
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

      default_scope where(:component_name => self.component_name)

      ActionController::Base.view_paths << Rails.root.join('lib', 'weby', 'components', self.component_name, 'views')
      Weby::Application.config.i18n.load_path += Dir[
        Rails.root.join('lib', 'weby', 'components', self.component_name, 'locales', '*.{rb,yml}').to_s
      ]
    end
  end
end
