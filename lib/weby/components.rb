module Weby

  module Components
    # Array de componentes disponíveis
    mattr_accessor :available_components
    @@available_components ||= []

    def self.setup
      yield self
    end
    
    ActionView::Helpers::RenderingHelper.module_eval do
      def render_component(component, view = 'show', args = {})
        args[:partial] = "components/#{component.class.component_name}/#{view.to_s}"
        
        args[:locals] ||= {}
        args[:locals].merge!({ :component => component })

        render args
      end
    end
  end
end
