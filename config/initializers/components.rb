require 'weby/components'

Weby::Components.setup do |setup|
  setup.available_components = Dir.glob(Rails.root.join('lib', 'weby', 'components', '*/*_component\.rb')).map do |i|
    # Pega o nome do arquivo sem a extensão
    # gov_bar_component.rb  # => gov_bar_component
    Object::const_get(i.split('/').last[0...-3].classify)
  end
end
