require 'spec_helper'

describe SimpleParams::ValidationMatchers::NonNumericalMatcher do
  class NonNumericalMatcherTestClass < SimpleParams::Params
    param :name
    param :age, optional: true, default: 37
    param :title, optional: true, default: "programmer"
  end

  subject { NonNumericalMatcherTestClass.new() }
  
  it { should have_non_numerical_value(:name) }
  it { should_not have_non_numerical_value(:age) }
  it { should have_non_numerical_value(:title) }
  
end