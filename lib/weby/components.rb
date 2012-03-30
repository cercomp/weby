module Weby

  module Components
    # Array de componentes disponíveis
    mattr_accessor :available_components
    @available_components ||= []

    def self.setup
      yield self
    end

    def self.factory(component)
      if component.class == SiteComponent
        build = Object::const_get("#{component.component.classify}Component").find(component.id)
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

        render args rescue ''
      end
    end
  end
end
