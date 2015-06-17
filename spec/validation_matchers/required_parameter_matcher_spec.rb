require 'spec_helper'

describe SimpleParams::ValidationMatchers::RequiredParameterMatcher do
  class RequiredParameterMatcherTestClass < SimpleParams::Params
    param :name
    param :age, optional: true
    param :title, default: "programmer"
    param :account_type, validations: { inclusion: { in: ["checking", "savings"] }}
    param :account_status, default: "active", validations: { inclusion: { in: ["active", "inactive"] }}
    param :username, type: :string, validations: { exclusion: { in: ['admin', 'demo'] } }
  end

  subject { RequiredParameterMatcherTestClass.new }
  
  it { should have_required_parameter(:name) }
  it { should_not have_required_parameter(:age) }
  it { should_not have_required_parameter(:name).with_default("Matthew") }
  it { should have_required_parameter(:title).with_default("programmer") }
  it { should have_required_parameter(:account_type).with_allowed_values("checking", "savings") }
  it { should have_required_parameter(:account_status).with_default("active").with_allowed_values("active", "inactive") }
  it { should have_required_parameter(:account_status).with_disallowed_values("admin", "demo") }
  it { should have_required_parameter(:username).with_allowed_values("myuser", "kitten") }
  it { should have_required_parameter(:username).with_disallowed_values("admin", "demo") }
end
