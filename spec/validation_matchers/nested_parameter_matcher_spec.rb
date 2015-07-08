require 'spec_helper'
require 'fixtures/validator_params'

describe SimpleParams::ValidationMatchers::NestedParameterMatcher do
  subject { ValidatorParams.new }

  it { should have_nested_parameter(:address) }
  it { should have_nested_parameter(:phone) }
  it { should_not have_nested_parameter(:dogs) } 
end
