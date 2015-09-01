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
  describe "class methods", class_methods: true do
    describe "define_nil_class" do
      let(:defined_class) do
        described_class.define_nil_class(DummyPersonParams)
      end

      it "has correct name" do
        defined_class.name.should eq("DummyPersonParams::NilParams")
      end

      it "has correct parent class" do
        defined_class.parent_class.should eq(DummyPersonParams)
      end

      it "has correct nested_classes" do
        defined_class.nested_classes.should eq({
          address: DummyPersonParams::Address, 
          phones: DummyPersonParams::Phones
        })
      end
    end
  end

  describe "public methods", public_methods: true do
    context "with no parent_class" do
      let!(:instance) { described_class.new({})}

      describe "#valid" do
        it "is valid" do
          instance.should be_valid
        end
      end

      describe "#errors" do
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
        it "is empty" do
          instance.to_hash.should be_empty
        end
      end

      describe "#mocked_params accessors" do
        it "does not respond to random accessors" do
          instance.should_not respond_to(:name)
          instance.should_not respond_to(:age)
        end
      end
    end

    context "with parent class" do
      let!(:instance) { described_class.define_nil_class(DummyPersonParams).new({})}

      describe "#valid" do
        it "is valid" do
          instance.should be_valid
        end
      end

      describe "#errors" do
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
        it "is empty" do
          instance.to_hash.should be_empty
        end
      end

      describe "#mocked_params accessors" do
        it "responds to parent class instance's accessors" do
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
end
