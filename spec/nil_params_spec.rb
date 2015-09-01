require 'spec_helper'

class DummyPersonParams < SimpleParams::Params
  param :name
  param :age, type: :integer
  nested_hash :address do
    param :street
    param :city
  end
  nested_array :phones do
    param :phone_number
  end
end

class DummyDogParams < SimpleParams::Params
  param :name
  param :age, type: :integer
  nested_hash :owners_address do
    param :street
    param :city
  end
  nested_array :puppies do
    param :name
    param :age
  end
end

describe SimpleParams::NilParams do
  # Turn off Constant Redefined errors
  before(:each) do
    $VERBOSE = nil
  end

  describe "class methods", class_methods: true do
    describe "nested_classes" do
      it "dynamically assigns nested classes based on mocked instance" do
        nil_params_1 = described_class.new({}, DummyPersonParams.new)
        nil_params_1.class.nested_classes.should eq({
          address: DummyPersonParams::Address, 
          phones: DummyPersonParams::Phones
        })
      end

      it "doesn't override assignment per instance" do
        nil_params_1 = described_class.new({}, DummyPersonParams.new)
        nil_params_2 = described_class.new({}, DummyDogParams.new)

        nil_params_1.class.nested_classes.should eq({
          address: DummyPersonParams::Address, 
          phones: DummyPersonParams::Phones
        })

        nil_params_2.class.nested_classes.should eq({
          owners_address: DummyDogParams::OwnersAddress, 
          puppies: DummyDogParams::Puppies
        })
      end
    end
  end

  describe "public methods", public_methods: true do
    let!(:mocked_params) { DummyPersonParams.new }

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
end
