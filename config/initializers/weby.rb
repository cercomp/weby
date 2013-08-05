require 'weby/content_i18n'
require 'weby/multisites'
require 'weby/form/show_errors'
require 'weby/components'
require 'weby/routing'
require 'weby/rights'
require 'weby/settings'
require 'weby/themes'

# Adiciona views dos componentes no path de views da aplicação
ActionController::Base.view_paths +=
  Dir[Rails.root.join('**', 'lib', '**', 'weby', '**', 'components')]

Weby::Application.config.assets.paths +=
  Dir[Rails.root.join('**', 'weby', '**', 'components', '**', 'assets', '*')]

# Inicializar os componentes
Dir.glob(File.join("**", "weby", "**", "components", "*", "init.rb")) do |rb_file|
  load rb_file
end

# Inicializar as extensoes
Dir.glob(File.join("vendor", "engines", "*", "init.rb")) do |rb_file|
  load rb_file
end

Weby::Bots.load_list
