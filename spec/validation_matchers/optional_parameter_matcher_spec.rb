require 'spec_helper'

describe SimpleParams::ValidationMatchers::OptionalParameterMatcher do
  class OptionalParameterMatcher < SimpleParams::Params
    param :name
    param :age, optional: true, default: "37"
    param :title, optional: true, default: "programmer"
  end

  subject { OptionalParameterMatcher.new }

  it { should_not have_optional_parameter(:name) }
  it { should have_optional_parameter(:age).with_default("37") }
  it { should have_optional_parameter(:title).with_default("programmer") }
end
