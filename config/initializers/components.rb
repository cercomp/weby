require 'weby/components'

# Adiciona views dos componentes no path de views da aplicação
ActionController::Base.view_paths +=
  Dir[Rails.root.join('lib', 'weby', 'components', '**', 'views')]

# Adiciona locales dos componentes no path de locales
Weby::Application.config.i18n.load_path +=
  Dir[Rails.root.join('lib', 'weby', 'components', '**', 'locales', '*.{rb,yml}').to_s]

# Adiciona assets dos componentes no path de assets
Weby::Application.config.assets.paths +=
  Dir[Rails.root.join('lib', 'weby', 'components', '**', 'assets', '**')]

Weby::Components.setup do |setup|
  # Vetor com todos os componentes
  setup.available_components = Dir.glob(Rails.root.join('lib', 'weby', 'components', '*/*_component\.rb')).map do |i|
    # Pega o nome do arquivo sem a extensão
    # gov_bar_component.rb  # => gov_bar_component
    i.split('/').last[0...-3].classify
  end
end
