require 'weby/components'

ActionController::Base.view_paths += Dir[Rails.root.join('lib', 'weby', 'components', '**', 'views')]
Weby::Application.config.i18n.load_path += Dir[
  Rails.root.join('lib', 'weby', 'components', '**', 'locales', '*.{rb,yml}').to_s
]

Weby::Components.setup do |setup|
  # Vetor com todos os componentes
  setup.available_components = Dir.glob(Rails.root.join('lib', 'weby', 'components', '*/*_component\.rb')).map do |i|
    # Pega o nome do arquivo sem a extensão
    # gov_bar_component.rb  # => gov_bar_component
    i.split('/').last[0...-3].classify
  end
end
