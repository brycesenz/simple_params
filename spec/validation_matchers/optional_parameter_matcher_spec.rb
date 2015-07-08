require 'spec_helper'
require 'fixtures/validator_params'

describe SimpleParams::ValidationMatchers::OptionalParameterMatcher do
  subject { ValidatorParams.new }

  it { should_not have_optional_parameter(:name) }
  it { should have_optional_parameter(:age).with_default(37) }
  it { should have_optional_parameter(:title).with_default("programmer") }
  it { should have_optional_parameter(:account_status).with_allowed_values("active", "inactive") }
  it { should have_optional_parameter(:account_type).with_default("checking").with_allowed_values("checking", "savings") }
  it { should have_optional_parameter(:account_type).with_disallowed_values("admin", "demo") }
  it { should_not have_optional_parameter(:username) }
end
