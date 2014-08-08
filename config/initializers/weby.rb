require 'weby/content_i18n'
require 'weby/multisites'
require 'weby/form/show_errors'
require 'weby/components'
require 'weby/routing'
require 'weby/rights'
require 'weby/settings'
require 'weby/themes'
require 'weby/assets'
require 'weby/webysettings'

# Adds the components views to the applications views path
ActionController::Base.view_paths +=
  Dir[Rails.root.join('**', 'lib', '**', 'weby', '**', 'components')]

Weby::Application.config.assets.paths +=
  Dir[Rails.root.join('lib', 'weby', 'institutions', 'assets', '*')]
Weby::Application.config.assets.paths +=
  Dir[Rails.root.join('**', 'weby', '**', 'components', '**', 'assets', '*')]

# Initialize the components
Dir.glob(File.join('**', 'weby', '**', 'components', '*', 'init.rb')) do |rb_file|
  load rb_file
end

# Initialize the extensions
Dir.glob(File.join('vendor', 'engines', '*', 'init.rb')) do |rb_file|
  load rb_file
end

Weby::Bots.load_list
