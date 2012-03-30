require 'weby/components'

# FIXME mudar para autoload
require 'weby/components/gov_bar/gov_bar_component'
require 'weby/components/weby_bar/weby_bar_component'
require 'weby/components/menu_side/menu_side_component'

Weby::Components.setup do |setup|
  setup.available_components = [
    GovBarComponent,
    WebyBarComponent,
    MenuSideComponent
  ]
end
