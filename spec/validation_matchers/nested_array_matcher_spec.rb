require 'spec_helper'
require 'fixtures/validator_params'

describe SimpleParams::ValidationMatchers::NestedArrayMatcher do
  subject { ValidatorParams.new }

  it { should have_nested_array(:dogs) }
  it { should_not have_nested_array(:address) } 
end
