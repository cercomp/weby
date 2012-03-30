require 'weby/components'

require 'weby/components/gov_bar/gov_bar_component'
require 'weby/components/weby_bar/weby_bar_component'

Weby::Components.setup do |setup|
  setup.available_components = [
    GovBarComponent,
    WebyBarComponent
  ]
end
