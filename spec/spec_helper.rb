require 'rubygems'
require 'bundler/setup'
require 'simple_params'

spec = Gem::Specification.find_by_name("simple_params")
gem_root = spec.gem_dir
Dir[("#{gem_root}/spec/support/**/*.rb")].each {|f| require f}
I18n.config.enforce_available_locales = true

RSpec.configure do |config|
  config.mock_with :rspec
end
