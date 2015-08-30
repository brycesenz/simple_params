require 'spec_helper'
require 'fixtures/dummy_params'

describe SimpleParams::NilParams do
  # Turn off Constant Redefined errors
  before(:each) do
    $VERBOSE = nil
  end

  let!(:mocked_params) { DummyParams.new }

  describe "#valid" do
    let(:instance) { described_class.new({}, mocked_params)}

    it "is valid" do
      instance.should be_valid
    end
  end

  describe "#errors" do
    let(:instance) { described_class.new({}, mocked_params)}

    it "has no errors" do
      instance.errors.should be_empty
    end

    it "can clear errors" do
      instance.valid?
      instance.errors.clear.should eq([])
    end

    it "has no error messages" do
      instance.valid?
      instance.errors.messages.should be_empty
    end
  end

  describe "#to_hash" do
    let(:instance) { described_class.new({}, mocked_params)}

    it "is empty" do
      instance.to_hash.should be_empty
    end
  end

  describe "#mocked_params accessors" do
    let(:instance) { described_class.new({}, mocked_params)}

    it "responds to mocked_params" do
      instance.name.should be_nil
      instance.age.should be_nil
      instance.name = "Amy"
      instance.age = 33
      instance.name.should eq("Amy")
      instance.age.should eq(33)
    end
  end
end
