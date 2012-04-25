module Weby

  module Components
    
    # Array de componentes disponíveis
    mattr_accessor :available_components

    def self.setup
      yield self
    end

    def self.factory(component)
      # A idéia é pegar um componente definido com a classe "Component" e passar
      # para a classe filha
      if component.class == Component
        build = Object::const_get("#{component.name.classify}Component").find(component.id)
      else
        ## FIXME verifica se o componente existe
        build = Object::const_get("#{component.classify}Component").new
      end

      return build
    end
    
    ActionView::Helpers::RenderingHelper.module_eval do
      def render_component(component, view = 'show', args = {})
        args[:partial] = "components/#{component.name}/#{view.to_s}"
        
        args[:locals] ||= {}
        args[:locals].merge!({ :component => component })

        # Caso a partial não exista, não mostra nada
        begin
          render args
        rescue ActionView::MissingTemplate
          ''
        end
      end
    end
  end

  module ComponentInstance
    def initialize_component(*settings)
      class_eval do
        # Como do componente que será usando em algumas partes do sistema
        def self.cname
          # Por padrão toda classe componente terá o "Component" no fim do nome, o come do
          # componente não precisa ter esse final
          # ex: GovBarComponent.tableize # => gov_bar_component.gsub(...) => gov_bar
          self.name.tableize.gsub(/_components$/, '')
        end

        # Inicializa o nome do componente quando ele é criado
        after_initialize do
          self.name = self.class.name.tableize.gsub(/_components$/, '')
        end
      end

      settings.each do |setting|
        class_eval <<-METHOD
          @#{setting}
          def #{setting}=(value)
            settings_map[:#{setting}] = value
          end
          
          def #{setting}
            settings_map[:#{setting}]
          end
        METHOD
      end

      default_scope where(:name => self.cname)
    end
  end
end
