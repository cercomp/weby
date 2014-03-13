source 'https://rubygems.org'

ruby '2.1.2'

gem 'rails', '~> 4.1.4'

gem 'thin', '~> 1.6.2'
gem 'pg', '~> 0.17.1'

# js and css frameworks
gem 'jquery-rails', '3.1.0'
gem 'jquery-ui-rails', '~> 4.2.1'
gem 'bootstrap-sass', '~> 3.1.1.1'
gem 'select2-rails', '~> 3.5.7'
gem 'd3js-rails', '~> 3.1.6'
gem 'jcrop-rails-v2', '~> 0.9.12.3'
gem 'font-awesome-rails', '~> 4.1.0.0'

# assets
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'therubyracer', :platforms => :ruby

gem 'simple_form', '~> 3.0.2'
gem 'rails-observers', '~> 0.1.2'
gem 'devise', '~> 3.2.4'
gem 'kaminari', '~> 0.15.1'
gem 'paperclip', :git => 'http://github.com/leo-souza/paperclip.git'
gem 'acts-as-taggable-on', '~> 3.2.6'
gem 'foreigner', '~> 1.6.1'
gem 'gretel', '~> 3.0.7'
gem 'zeroclipboard-rails', '~> 0.0.13'
gem 'zip-zip', '~> 0.3'

gem 'useragent', '0.2.3', :git => 'http://github.com/jilion/useragent'
gem 'rails-settings-cached', '0.4.1'

group :development, :test do
  gem 'rspec-rails', '~> 3.0.1'
end

group :development do
  gem 'binding_of_caller', '~> 0.7.2'
  gem 'better_errors', '~> 1.1.0'
  gem 'meta_request', '~> 0.3.0'
  gem 'pry-rails', '~> 0.3.2'
  gem 'letter_opener', '~> 1.2.0'
end

group :test do
  gem 'shoulda-matchers', '~> 2.6.1'
  gem 'factory_girl_rails', '~> 4.4.1'
  gem 'selenium-webdriver', '~> 2.42.0'
  gem 'capybara'
  gem 'capybara-webkit'
end

#Extensions gems
Dir.glob(File.join('vendor', 'engines', '*')) do |file|
  gem file.split('/')[-1], :path => file
end
eval(File.read('Gemfile-ext')) if File.exists?('Gemfile-ext')
