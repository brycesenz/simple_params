require 'spec_helper'

shared_examples "a base attribute" do

  let(:base_attribute) { described_class.new(simple_param_attribute) }

  describe 'base_attribute' do
    specify 'should respond to do_not_document' do
      expect(base_attribute.respond_to?(:do_not_document?, true)).to be_truthy
    end

    specify 'should respond to description' do
      expect(base_attribute.respond_to?(:requirement_description, true)).to be_truthy
    end

    specify 'should respond to description' do
      expect(base_attribute.respond_to?(:description, true)).to be_truthy
    end
  end
end

