require 'spec_helper'

describe SimpleParams::ValidationMatchers::OptionalParameterMatcher do
  class OptionalParameterMatcher < SimpleParams::Params
    param :name
    param :age, optional: true, default: 37
    param :title, optional: true, default: "programmer"
    param :account_type, default: "checking", validations: { inclusion: { in: ["checking", "savings"] }}
    param :account_status, optional: true, validations: { inclusion: { in: ["active, inactive"] }}
  end

  subject { OptionalParameterMatcher.new }

  it { should_not have_optional_parameter(:name) }
  it { should have_optional_parameter(:age).with_default(37) }
  it { should have_optional_parameter(:title).with_default("programmer") }
  it { should have_optional_parameter(:account_status).with_allowed_values("active", "inactive") }
  it { should have_optional_parameter(:account_type).with_default("checking").with_allowed_values("checking", "savings") }

end
