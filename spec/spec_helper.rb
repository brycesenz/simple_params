require 'rubygems'
require 'bundler/setup'
require 'simple_params'
require 'pry'
require 'support/base_attribute_spec'

I18n.config.enforce_available_locales = true

RSpec.configure do |config|
  config.mock_with :rspec
end
