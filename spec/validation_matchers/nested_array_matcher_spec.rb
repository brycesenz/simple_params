require 'spec_helper'

describe SimpleParams::ValidationMatchers::NestedArrayMatcher do
  class NestedArrayMatcherTestClass < SimpleParams::Params
    param :name
    param :age, optional: true, default: 37
    nested_array :dogs do
      param :name
      param :age, type: :integer
    end
  end

  subject { NestedArrayMatcherTestClass.new }

  it { should have_nested_array(:dogs) }
  it { should_not have_nested_array(:broken) } 
end
