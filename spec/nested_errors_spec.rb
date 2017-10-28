require 'spec_helper'

describe SimpleParams::NestedErrors do
  class Car
    extend ActiveModel::Naming
    def initialize
      @errors = SimpleParams::NestedErrors.new(self)
    end

    attr_accessor :make
    attr_accessor :model
    attr_reader   :errors

    def array?; false; end
    def hash?; true; end

    def read_attribute_for_validation(attr)
      send(attr)
    end

    def self.human_attribute_name(attr, options = {})
      attr
    end

    def self.lookup_ancestors
      [self]
    end
  end

  class Plane
    extend ActiveModel::Naming
    def initialize
      @errors = SimpleParams::NestedErrors.new(self)
    end

    attr_accessor :pilot
    attr_accessor :number
    attr_reader   :errors

    def array?; true; end
    def hash?; false; end

    def read_attribute_for_validation(attr)
      send(attr)
    end

    def self.human_attribute_name(attr, options = {})
      attr
    end

    def self.lookup_ancestors
      [self]
    end
  end

  describe '[]', getter: true do
    it "gets the errors for the provided key" do
      errors = SimpleParams::NestedErrors.new(self)
      errors.add(:foo, "omg")
      errors[:foo].should eq(["omg"])
    end

    it "gets model errors" do
      car = Car.new
      car.errors.add(:make, "can not be blank")
      car.errors.add(:make, "can not be nil")
      car.errors[:make].should eq(["can not be blank", "can not be nil"])
    end
  end

  describe '[]=', setter: true do
    it "sets the errors for the provided key" do
      errors = SimpleParams::Errors.new(self)
      errors[:foo] = "omg"
      errors[:foo].should eq(["omg"])
    end

    it "sets model errors" do
      car = Car.new
      car.errors[:make] = "can not be blank"
      car.errors[:make].should eq(["can not be blank"])
    end
  end

  describe "#clear", clear: true do
    it "clears errors" do
      car = Car.new
      car.errors[:make] = 'should not be nil'
      car.errors[:make].should eq(["should not be nil"])
      car.errors.clear
      car.errors.should be_empty
    end
  end

  describe "#empty?, #blank?, and #include?", empty: true do
    it "is empty without any errors" do
      car = Car.new
      car.errors.should be_empty
      car.errors.should be_blank
      car.errors.should_not have_key(:make)
    end

    it "is not empty with errors" do
      car = Car.new
      car.errors[:make] = 'should not be nil'
      car.errors.should_not be_empty
      car.errors.should_not be_blank
      car.errors.should have_key(:make)
    end
  end

  describe "#size", size: true do
    it "size calculates the number of error messages" do
      car = Car.new
      car.errors.add(:make, "can not be blank")
      car.errors.size.should eq(1)
    end
  end

  describe "#to_a", to_a: true do
    it "to_a returns the list of errors with complete messages containing the attribute names" do
      car = Car.new
      car.errors.add(:make, "can not be blank")
      car.errors.add(:make, "can not be nil")
      car.errors.to_a.should eq(["make can not be blank", "make can not be nil"])
    end
  end

  describe "#to_s", to_s: true do
    it "to_a returns the list of errors with complete messages containing the attribute names" do
      car = Car.new
      car.errors.add(:make, "can not be blank")
      car.errors.add(:make, "can not be nil")
      car.errors.to_s.should eq("make can not be blank, make can not be nil")
    end
  end

  describe "#to_hash", to_hash: true do
    it "to_hash returns the error messages hash" do
      car = Car.new
      car.errors.add(:make, "can not be blank")
      car.errors.to_hash.should eq({ make: ["can not be blank"] })
    end
  end

  describe "#as_json", as_json: true do
    it "as_json creates a json formatted representation of the errors hash" do
      car = Car.new
      car.errors[:make] = 'can not be nil'
      car.errors[:make].should eq(["can not be nil"])
      car.errors.as_json.should eq({ make: ["can not be nil"] })
    end

    it "as_json with :full_messages option creates a json formatted representation of the errors containing complete messages" do
      car = Car.new
      car.errors[:make] = 'can not be nil'
      car.errors[:make].should eq(["can not be nil"])
      car.errors.as_json(full_messages: true).should eq({ make: ["make can not be nil"] })
    end    
  end

  describe "#full_messages", full_messages: true do
    it "full_messages creates a list of error messages with the attribute name included" do
      car = Car.new
      car.errors.add(:make, "can not be blank")
      car.errors.add(:make, "can not be nil")
      car.errors.full_messages.should eq(["make can not be blank", "make can not be nil"])
    end

    it "full_messages_for contains all the error messages for the given attribute" do
      car = Car.new
      car.errors.add(:make, "can not be blank")
      car.errors.add(:make, "can not be nil")
      car.errors.full_messages_for(:make).should eq(["make can not be blank", "make can not be nil"])
    end

    it "full_messages_for does not contain error messages from other attributes" do
      car = Car.new
      car.errors.add(:make, "can not be blank")
      car.errors.add(:model, "can not be blank")
      car.errors.full_messages_for(:make).should eq(["make can not be blank"])
    end

    it "full_messages_for returns an empty list in case there are no errors for the given attribute" do
      car = Car.new
      car.errors.add(:make, "can not be blank")
      car.errors.full_messages_for(:model).should eq([])
    end

    it "full_message returns the given message when attribute is :base" do
      car = Car.new
      car.errors.full_message(:base, "press the button").should eq("press the button")
    end

    it "full_message returns the given message with the attribute name included" do
      car = Car.new
      car.errors.full_message(:make, "can not be blank").should eq("make can not be blank")
      car.errors.full_message(:model, "can not be blank").should eq("model can not be blank")
    end
  end

  describe "#generate_message", generate_message: true do
    it "generate_message works without i18n_scope" do
      car = Car.new
      Car.should_not respond_to(:i18n_scope)
      expect {
        car.errors.generate_message(:make, :blank)
      }.to_not raise_error
    end
  end
end
