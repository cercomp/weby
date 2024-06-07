source 'http://rubygems.org'

ruby '2.7.5'

gem 'rails', '5.2.4.2'
gem 'rake', '13.0.1'

gem 'thin', '~> 1.7.2'
gem 'pg', '~> 1.2.3'

gem 'bootsnap', '~> 1.4.6', require: false

# js and css frameworks
gem 'jquery-rails', '4.5.1'
gem 'jquery-ui-rails', '~> 6.0.1'
gem 'bootstrap-sass', '~> 3.4.1'
gem 'cropper-rails', '~> 2.3.2.1'
gem 'font-awesome-rails', '~> 4.7.0.5'
gem 'fullcalendar-rails'

#storage
gem 'aws-sdk-s3', '~> 1'
gem 'fog-aws'
gem 'asset_sync'

#elastic
gem 'searchkick', '~> 4.3.0'
gem 'elasticsearch', '~> 7.6.0'
gem 'oj' #boost json parsing

# Ominiauth
gem 'omniauth-shibboleth'

# assets
gem 'sprockets', '3.7.2'
gem 'sprockets-rails', '3.4.2'
gem 'sassc-rails', '2.1.2'
gem 'terser', '~> 1.1.12'
#gem 'therubyracer', platforms: :ruby
gem 'non-stupid-digest-assets' # Generate assets without digest.

gem 'simple_form', '~> 5.0.2'
gem 'rails-observers', '~> 0.1.5'
gem 'devise', '~> 4.8.1'
gem 'kaminari', '~> 1.2.0'
gem 'paperclip', :git => 'http://github.com/leo-souza/paperclip.git'
gem 'acts-as-taggable-on', '~> 6.5.0'
gem 'gretel', '~> 3.0.9'
gem 'clipboard-rails', '~> 1.7.1'
gem 'zip-zip', '~> 0.3'
gem "nori"
gem 'simple_captcha2', require: 'simple_captcha'
gem 'active_model_serializers'
gem 'activemodel-serializers-xml'

gem 'useragent', '0.2.3', :git => 'http://github.com/jilion/useragent'

gem 'net-ldap', '~> 0.16.0'
gem 'prawn', '~> 2.0.1'
gem 'prawn-table', '~> 0.2.1'
gem 'momentjs-rails', '~> 2.20.1'
gem 'bootstrap-daterangepicker-rails', '~> 3.0.4'
gem 'redcarpet', '~> 3.5.1'

# error tracking
gem 'rollbar'

gem 'rails-html-sanitizer', '~> 1.3.0'

#rswag
gem 'rswag'
gem 'rswag-specs'
gem 'bigdecimal', '1.4.2'

# rails assets org
source 'https://rails-assets.org' do
  gem 'rails-assets-tinymce', '~> 4.8.5'
  gem 'rails-assets-select2', '~> 3.5.4'
  #gem 'rails-assets-d3', '~> 5.7.0'
end

group :development, :test do
  gem 'rspec-rails', '~> 3.9.1'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'dotenv-rails', '~>2.7.5'
end

group :development do
  gem 'binding_of_caller', '~> 0.8.0'
  gem 'better_errors', '~> 1.1.0'
  gem 'meta_request', '~> 0.7.0'
  gem 'letter_opener', '~> 1.2.0'
  gem 'bullet'
end

group :test do
  gem 'shoulda-matchers', '~> 2.6.1'
  gem 'factory_girl_rails', '~> 4.4.1'
  gem 'selenium-webdriver', '~> 3.142.5'
  gem 'capybara'
end

#Extensions gems
Dir.glob(File.join('vendor', 'engines', '*')) do |file|
  gem file.split('/')[-1], :path => file
end
eval(File.read('Gemfile-ext')) if File.exists?('Gemfile-ext')
