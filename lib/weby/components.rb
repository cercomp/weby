module Weby

  module Components
    
    ActionView::PartialRenderer.module_eval do
      def render_component(component, view = 'index')
        render "components/#{component.component_name}/#{view}"
      end
    end
  end
end
