require 'spec_helper'
require 'fixtures/validator_params'

describe SimpleParams::ValidationMatchers::RequiredParameterMatcher do
  subject { ValidatorParams.new }

  it { should have_required_parameter(:name) }
  it { should_not have_required_parameter(:age) }
  it { should_not have_required_parameter(:name).with_default("Matthew") }
  it { should have_required_parameter(:title).with_default("programmer") }
  it { should have_required_parameter(:account_type).with_default("checking").with_allowed_values("checking", "savings") }
  it { should have_required_parameter(:account_status).with_default("active").with_allowed_values("active", "inactive") }
  it { should have_required_parameter(:account_status).with_disallowed_values("admin", "demo") }
  it { should have_required_parameter(:username).with_allowed_values("myuser", "kitten") }
  it { should have_required_parameter(:username).with_disallowed_values("admin", "demo") }
end
