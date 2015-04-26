require 'spec_helper'
require 'simple_params/custom_matchers/have_required_param'

describe SimpleParams::TestCustomMatchers::DummyClass do
  it { should have_required_parameter(:name) }
  it { should_not validate_presence_of(:age) }
  it { should have_optional_parameter("", nil).for(:age) }
end

