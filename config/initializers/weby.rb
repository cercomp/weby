require 'weby/content_i18n'
require 'weby/multisites'
require 'weby/form/show_errors'
require 'weby/components'

# Adiciona views dos componentes no path de views da aplicação
ActionController::Base.view_paths +=
  Dir[Rails.root.join('lib', 'weby', 'components')]

# Inicializar os componentes
Dir.glob('lib/weby/components/**/init.rb') do |rb_file|
  load rb_file
end


