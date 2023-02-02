require 'weby/content_i18n'
require 'weby/multisites'
require 'weby/form/show_errors'
require 'weby/components'
require 'weby/routing'
require 'weby/rights'
require 'weby/settings'
require 'weby/themes'
require 'weby/assets'
require './db/data_migrations/theme_migration'

# Adds the components and theme views to the applications views path
ActionController::Base.view_paths +=
  Dir[Rails.root.join('**', 'lib', '**', 'weby', '**', 'components')]
ActionController::Base.view_paths +=
    Dir[Rails.root.join('lib', 'weby', 'themes', '*')]

Rails.application.config.assets.paths +=
  Dir[Rails.root.join('**', 'weby', '**', 'components', '**', 'assets', '*')]
Rails.application.config.assets.paths +=
    Dir[Rails.root.join('lib', 'weby', 'themes', '*', 'assets', '*')]

# Initialize the components
Dir.glob(File.join('**', 'weby', '**', 'components', '*', 'init.rb')) do |rb_file|
  load rb_file
end

# Initialize the extensions
Dir.glob(File.join('vendor', 'engines', '*', 'init.rb')) do |rb_file|
  load rb_file
end
# extensions from core
Dir.children(Rails.root.join('lib', 'weby', 'extensions')).each do |file|
  file.gsub!('.rb', '')
  require "weby/extensions/#{file}"
  ::Weby::register_extension(Weby::Extension.new(file.to_sym, author: 'Cercomp - Equipe Web', menu_position: eval(file.to_s.titleize)::POSITION, settings: [:from_core, :photos_limit, :show_author, :show_created_at, :limit_photo_size]))
end


Weby::Bots.load_list
