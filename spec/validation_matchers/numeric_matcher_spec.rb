require 'spec_helper'

describe SimpleParams::ValidationMatchers::NumericMatcher do
  class NumericMatcherTestClass < SimpleParams::Params
    param :name
    param :age, optional: true, default: 37
    param :title, optional: true, default: "programmer"
  end

  subject { NumericMatcherTestClass.new() }
  
  it { should_not have_numeric_value(:name) }
  it { should have_numeric_value(:age) }
  it { should_not have_numeric_value(:title) }
  
end