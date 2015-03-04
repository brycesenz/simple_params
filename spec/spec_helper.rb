require 'rubygems'
require 'bundler/setup'
require 'simple_params'

Dir[("../spec/support/**/*.rb")].each {|f| require f}

I18n.config.enforce_available_locales = true

RSpec.configure do |config|
  config.mock_with :rspec
end
