source 'https://rubygems.org'
ruby '2.0.0'

gem 'rails', '3.2.13'
gem 'thin', '1.5.1'
gem 'jquery-rails', '2.1.4'
gem 'pg', '0.14.1'
gem 'authlogic', '3.1.3' 
gem 'kaminari', '0.14.1'
gem 'paperclip', :tag => 'v3.5.1', :git => 'http://github.com/thoughtbot/paperclip.git'
gem 'acts_as_list', '0.1.9'
gem 'simple_form', :tag => 'v2.0.1', :git => 'http://github.com/plataformatec/simple_form.git'
gem 'acts-as-taggable-on', :git => 'https://github.com/mbleigh/acts-as-taggable-on.git'
gem 'bootstrap-sass', '2.3.0.1'
gem 'foreigner'
gem "select2-rails"
gem 'd3js-rails'
gem "gretel"

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'therubyracer', '0.10.2'
  gem 'uglifier', '>= 1.0.3'
end

group :production do
  gem 'dispatcher', '0.0.1'
  gem 'turbo-sprockets-rails3'
end

group :development, :test do
  gem 'railroady'
  gem 'meta_request', '0.2.0'
  gem 'pry-rails', '0.2.2'
  gem 'rspec-rails', '2.9.0'
  gem 'factory_girl_rails', '1.7.0'
  gem 'shoulda-matchers', '1.0.0'
  gem 'sqlite3'
  gem 'debugger', '1.6.0'
end

group :development do
  gem "binding_of_caller"
  gem "better_errors"
end

#Extensions (engines)
gem 'acadufg', :path => 'vendor/engines/acadufg'
gem 'feedback', :path => 'vendor/engines/feedback'
#Dir.glob(File.dirname(__FILE__) + '/vendor/engines/*/*.gemspec').each do |engine_gemspec|
#  gemspec :path => File.dirname(engine_gemspec)
#end

