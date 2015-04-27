require 'spec_helper'

describe SimpleParams::ValidationMatchers::OptionalParameterMatcher do
  class OptionalParameterMatcher < SimpleParams::Params
    param :name
    param :age, optional: true
  end

  subject { OptionalParameterMatcher.new }

  it { should_not have_optional_parameter(:name) }
  it { should have_optional_parameter(:age) }
end
