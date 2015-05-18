require 'spec_helper'

describe SimpleParams::ValidationMatchers::NestedParameterMatcher do
  class NestedParameterMatcherTestClass < SimpleParams::Params
    param :name
    param :age, optional: true, default: 37
    param :title, optional: true, default: "programmer"
    param :account_type, default: "checking", validations: { inclusion: { in: ["checking", "savings"] }}
    param :account_status, optional: true, validations: { inclusion: { in: ["active", "inactive"] }}
    nested_param :billing_address do
      param :first_name
      param :last_name
      param :company, optional: true
      param :street
      param :city
      param :state
      param :zip_code
      param :country
    end
  end

  subject { NestedParameterMatcherTestClass.new }

  it { should have_nested_parameter(:billing_address) }
  it { should_not have_nested_parameter(:broken) } 
end
