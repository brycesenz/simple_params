require 'spec_helper'
require 'simple_params/custom_matchers/have_required_param'

describe SimpleParams::TestCustomMatchers::DummyClass do 
	it { should have_required_parameter(:name) }
	it { should have_optional_parameter(:age) }
end

