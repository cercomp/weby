source 'https://rubygems.org'

gem 'rails', '3.2.1'
gem 'mongrel', '>= 1.2.0.pre2'
gem "jquery-rails"
gem 'pg'
gem 'authlogic'
gem 'kaminari'
gem "paperclip", :git => "http://github.com/thoughtbot/paperclip.git" 
gem "acts_as_list"
gem "simple_form", '2.0.1'
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
  gem 'rspec-rails'
end
