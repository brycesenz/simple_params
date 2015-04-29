require 'rubygems'
require 'bundler/setup'
require 'simple_params'
require 'shoulda/matchers'
require 'pry'

Dir[File.join('.', 'spec', 'support', '**', '*.rb')].each {|f| require f}

I18n.config.enforce_available_locales = true

RSpec.configure do |config|
  config.mock_with :rspec
  config.include(SimpleParams::ValidationMatchers)
end
