require 'spec_helper'

describe SimpleParams::ValidationMatchers::RequiredParameterMatcher do
  class RequiredParameterMatcherTestClass < SimpleParams::Params
    param :name
    param :age, optional: true
  end

  subject { RequiredParameterMatcherTestClass.new }

  it { should have_required_parameter(:name) }
  it { should_not have_required_parameter(:age) }
end
