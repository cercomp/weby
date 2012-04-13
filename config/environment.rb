# Load the rails application
require File.expand_path('../application', __FILE__)
require 'weby/content_i18n/base'
require 'weby/form/show_errors'

# Initialize the rails application
Weby::Application.initialize!
