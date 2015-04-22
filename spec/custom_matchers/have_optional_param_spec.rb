require 'spec_helper'
require 'simple_params/test_custom_matchers/dummy_class'

describe SimpleParams::CustomMatchers::HaveOptionalParam do

	context 'optional param no value' do
		let(:params) { SimpleParams::TestCustomMatchers::DummyClass.new(name: "Matthew", age: "") }

		it "should validate optional parameter" do
	    params.age.should be_nil
		end
  end

  context 'optional param value' do
		let(:params) { SimpleParams::TestCustomMatchers::DummyClass.new(name: "Matthew", age: "1") }

		it "should not validate optional parameter" do
			params.age.should_not be_nil
		end
	end
end