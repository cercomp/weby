module Weby
  module Components
    
    # Array de componentes disponíveis
    mattr_accessor :available_components

    def self.setup
      yield self
    end

    # Plugin constructor
    def self.register_component(comp_name, config={})

      require "weby/components/#{comp_name.to_s}/#{comp_name.to_s}_component"

      # Adiciona locales do componente no path de locales
      Weby::Application.config.i18n.load_path +=
        Dir[Rails.root.join('lib', 'weby', 'components', comp_name.to_s, 'locales', '*.{rb,yml}').to_s]

      unless config[:enabled]==false
        # Adiciona assets do componente no path de assets
        Weby::Application.config.assets.paths +=
          Dir[Rails.root.join('lib', 'weby', 'components', comp_name.to_s, 'assets', '**')]

        self.available_components ||= []
        self.available_components << comp_name
      end

    end

    def self.is_available?(comp_name)
      return self.available_components.include?(comp_name.to_sym)
    end

    def self.factory(component)
      # A idéia é pegar um componente definido com a classe "Component" e passar
      # para a classe filha
      if component.class == Component
        build = Object::const_get("#{component.name.classify}Component").instantiate(component.attributes)
      else
        ## FIXME verifica se o componente existe
        build = Object::const_get("#{component.classify}Component").new
      end

      return build
    end
    
    ActionView::Helpers::RenderingHelper.module_eval do
      def render_component(component, view = 'show', args = {})
        args[:partial] = "#{component.name}/views/#{view.to_s}"
        
        args[:locals] ||= {}
        args[:locals].merge!({ :component => component })

        # Caso a partial não exista, não mostra nada
        begin
          output = render args
          if Weby::Application.assets.find_asset("#{component.name}")
            @styesheets_loaded ||= []
            #Incluir o css do componente somente uma vez, mesmo se existirem mais de um sendo exibido
            unless(@styesheets_loaded.include?(component.name))
              output += stylesheet_link_tag("#{component.name}")
              @styesheets_loaded << component.name
            end
          end
        rescue ActionView::MissingTemplate
          output = ''
        end
        output
      end
    end
  end

  module ComponentInstance
    def component_settings(*settings)
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
