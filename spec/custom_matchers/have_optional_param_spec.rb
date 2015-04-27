require 'spec_helper'
require 'simple_params/test_custom_matchers/dummy_class'

describe SimpleParams::CustomMatchers::HaveOptionalParam do

  context 'should allow nil value' do
    subject { SimpleParams::TestCustomMatchers::DummyClass.new(name: "Matthew", age: "") }

    it "should validate optional parameter" do
      subject.should validate_presence_of(:name)
      subject.should_not have_optional_parameter("", nil).for(:name)
      subject.should_not validate_presence_of(:age)
      subject.should have_optional_parameter("", nil).for(:age)
    end
  end
end