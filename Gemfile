source 'https://rubygems.org'

gem 'rails', '3.2.1'
gem 'mongrel', '>= 1.2.0.pre2'
gem "jquery-rails"
gem 'pg'
gem 'authlogic'
gem 'kaminari'
gem "paperclip", :git => "http://github.com/thoughtbot/paperclip.git" 
gem "acts_as_list"
gem "simple_form", :tag => 'v2.0.1', :git => "http://github.com/plataformatec/simple_form.git"
gem "acts-as-taggable-on"

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'therubyracer'
  gem 'uglifier', '>= 1.0.3'
end

group :production do
  gem 'dispatcher'
  gem 'thin' # Optional, needs for thin cluster in production
end

group :development do
  gem 'pry-rails'
end

group :development, :test do
  gem 'rspec-rails', '2.8.1'
  gem 'factory_girl_rails', '1.7.0'
  gem 'valid_attribute', '1.2.0'
end
