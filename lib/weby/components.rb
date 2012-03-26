module Weby

  module Components
    def self.setup
      yield self
    end
    
    ActionView::Helpers::RenderingHelper.module_eval do
      def render_component(component, view = 'show')
        render :partial => "components/#{component.class.component_name}/#{view.to_s}",
          :locals => { :component => component }
      end
    end

    # Como carregar todos de uma vez?
    require 'weby/components/gov_bar/gov_bar_component'
    require 'weby/components/weby_bar/weby_bar_component'
  end
end
