require 'capybara/rspec'

Capybara.configure do |config|
  config.default_driver = :webkit
  config.ignore_hidden_elements = :true
end
