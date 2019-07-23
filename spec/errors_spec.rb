require 'spec_helper'

describe SimpleParams::Errors do
  class Person
    extend ActiveModel::Naming
    def initialize
      @errors = SimpleParams::Errors.new(self, {dog: dog, cats: cats})
    end

    attr_accessor :name, :age
    attr_reader   :errors

    def dog
      @dog ||= Dog.new
    end

    def cats
      @cats ||= [Cat.new]
    end

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

  class Dog
    extend ActiveModel::Naming
    def initialize
      @errors = SimpleParams::Errors.new(self)
    end

    attr_accessor :breed
    attr_reader   :errors

    def id
      nil
    end

    def parent_attribute_name
      :dog
    end

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

  class Cat
    extend ActiveModel::Naming
    def initialize
      @errors = SimpleParams::Errors.new(self)
    end

    attr_accessor :name
    attr_accessor :age
    attr_reader   :errors

    def id
      123
    end

    def parent_attribute_name
      :cats
    end

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
      errors = SimpleParams::Errors.new(self)
      errors.add(:foo, "omg")
      errors[:foo].should eq(["omg"])
    end

    it "gets model with nested attributes" do
      person = Person.new
      person.errors.add(:name, "can not be blank")
      person.errors.add(:name, "can not be nil")
      person.errors[:name].should eq(["can not be blank", "can not be nil"])
    end

    it "gets nested model errors" do
      person = Person.new
      person.dog.errors.add(:breed, "can not be blank")
      person.errors[:dog][:breed].should eq(["can not be blank"])
    end

    it "gets nested model errors" do
      person = Person.new
      person.cats.first.errors.add(:name, "can not be blank")
      person.errors[:cats][0][:name].should eq(["can not be blank"])
    end
  end

  describe '[]=', setter: true do
    it "sets the errors for the provided key" do
      errors = SimpleParams::Errors.new(self)
      errors[:foo] = "omg"
      errors[:foo].should eq(["omg"])
    end

    it "sets model with nested attributes" do
      person = Person.new
      person.errors[:name] = "can not be blank"
      person.errors[:name].should eq(["can not be blank"])
    end

    it "sets nested model errors" do
      person = Person.new
      person.dog.errors[:breed] = "can not be blank"
      person.errors[:dog][:breed].should eq(["can not be blank"])
    end

    it "sets nested model errors" do
      person = Person.new
      person.cats.first.errors[:name] = "can not be blank"
      person.errors[:cats][0][:name].should eq(["can not be blank"])
    end
  end

  describe "#clear", clear: true do
    it "clears errors" do
      person = Person.new
      person.errors[:name] = 'should not be nil'
      person.errors[:name].should eq(["should not be nil"])
      person.errors.clear
      person.errors.should be_empty
    end

    it "clears nested errors" do
      person = Person.new
      person.errors[:name] = 'should not be nil'
      person.errors[:name].should eq(["should not be nil"])
      person.errors[:dog] = 'should not be nil'
      person.dog.errors[:base].should eq(['should not be nil'])
      person.errors.clear
      person.errors.should be_empty
      person.dog.errors.should be_empty
    end
  end

  describe "#empty?, #blank?, and #include?", empty: true do
    it "is empty without any errors" do
      person = Person.new
      person.errors.should be_empty
      person.errors.should be_blank
      person.errors.should_not have_key(:name)
      person.errors.should_not have_key(:dog)
    end

    it "is not empty with errors" do
      person = Person.new
      person.errors[:name] = 'should not be nil'
      person.errors.should_not be_empty
      person.errors.should_not be_blank
      person.errors.should have_key(:name)
      person.errors.should_not have_key(:dog)
    end

    it "is not empty with nested errors" do
      person = Person.new
      person.errors[:dog] = 'should not be nil'
      person.errors.should_not be_empty
      person.errors.should_not be_blank
      person.errors.should_not have_key(:name)
      person.errors.should have_key(:dog)
    end
  end

  describe "#size", size: true do
    it "size calculates the number of error messages" do
      person = Person.new
      person.errors.add(:name, "can not be blank")
      person.errors.size.should eq(1)
    end

    it "includes nested attributes in size count" do
      person = Person.new
      person.errors.add(:dog, "can not be blank")
      person.errors.size.should eq(1)
    end
  end

  describe "#to_a", to_a: true do
    it "to_a returns the list of errors with complete messages containing the attribute names" do
      person = Person.new
      person.errors.add(:name, "can not be blank")
      person.errors.add(:name, "can not be nil")
      person.errors.to_a.should eq(["name can not be blank", "name can not be nil"])
    end

    it "handles nested attributes" do
      person = Person.new
      person.errors.add(:name, "can not be blank")
      person.dog.errors.add(:breed, "can not be nil")
      person.errors.to_a.should eq(["name can not be blank", "dog breed can not be nil"])
    end
  end

  describe "#to_s", to_s: true do
    it "to_a returns the list of errors with complete messages containing the attribute names" do
      person = Person.new
      person.errors.add(:name, "can not be blank")
      person.errors.add(:name, "can not be nil")
      person.errors.to_s.should eq("name can not be blank, name can not be nil")
    end

    it "handles nested attributes" do
      person = Person.new
      person.errors.add(:name, "can not be blank")
      person.dog.errors.add(:breed, "can not be nil")
      person.errors.to_s.should eq("name can not be blank, dog breed can not be nil")
    end
  end

  describe "#to_hash", to_hash: true do
    it "to_hash returns the error messages hash" do
      person = Person.new
      person.errors.add(:name, "can not be blank")
      person.errors.to_hash.should eq({ name: ["can not be blank"] })
    end

    it "handles nested attributes" do
      person = Person.new
      person.errors.add(:name, "can not be blank")
      person.dog.errors.add(:breed, "can not be nil")
      person.errors.to_hash.should eq({
        name: ["can not be blank"],
        dog: {
          breed: ["can not be nil"]
        }
      })
    end

    it "handles nested attributes with base errors" do
      person = Person.new
      person.errors.add(:base, :invalid)
      person.errors.add(:name, "can not be blank")
      person.dog.errors.add(:base, :invalid)
      person.dog.errors.add(:breed, "can not be nil")
      person.errors.to_hash.should eq({
        base: ["is invalid"],
        name: ["can not be blank"],
        dog: {
          base: ["is invalid"],
          breed: ["can not be nil"]
        }
      })
    end

    it "handles nested attributes with base errors and array errors" do
      person = Person.new
      person.errors.add(:base, :invalid)
      person.errors.add(:name, "can not be blank")
      person.dog.errors.add(:base, :invalid)
      person.dog.errors.add(:breed, "can not be nil")
      person.cats.first.errors.add(:name, "can not be blank")
      person.errors.to_hash.should eq({
        base: ["is invalid"],
        name: ["can not be blank"],
        dog: {
          base: ["is invalid"],
          breed: ["can not be nil"]
        },
        cats: [
          {
            name: ["can not be blank"]
          }
        ]
      })
    end
  end

  describe "#as_json", as_json: true do
    it "as_json creates a json formatted representation of the errors hash" do
      person = Person.new
      person.errors[:name] = 'can not be nil'
      person.errors[:name].should eq(["can not be nil"])
      person.errors.as_json.should eq({ name: ["can not be nil"] })
    end

    it "as_json with :full_messages option creates a json formatted representation of the errors containing complete messages" do
      person = Person.new
      person.errors[:name] = 'can not be nil'
      person.errors[:name].should eq(["can not be nil"])
      person.errors.as_json(full_messages: true).should eq({ name: ["name can not be nil"] })
    end

    it "handles nested attributes without full_messages" do
      person = Person.new
      person.errors[:name] = 'can not be nil'
      person.dog.errors[:breed] = 'is invalid'
      person.errors.as_json.should eq({
        name: ["can not be nil"],
        dog: {
          breed: ["is invalid"]
        }
      })
    end

    it "handles nested attributes with full_messages" do
      person = Person.new
      person.errors[:name] = 'can not be nil'
      person.dog.errors[:breed] = 'is invalid'
      person.errors.as_json(full_messages: true).should eq({
        name: ["name can not be nil"],
        dog: {
          breed: ["breed is invalid"]
        }
      })
    end
  end

  describe "#full_messages", full_messages: true do
    it "full_messages creates a list of error messages with the attribute name included" do
      person = Person.new
      person.errors.add(:name, "can not be blank")
      person.errors.add(:name, "can not be nil")
      person.errors.full_messages.should eq(["name can not be blank", "name can not be nil"])
    end

    it "full_messages_for contains all the error messages for the given attribute" do
      person = Person.new
      person.errors.add(:name, "can not be blank")
      person.errors.add(:name, "can not be nil")
      person.errors.full_messages_for(:name).should eq(["name can not be blank", "name can not be nil"])
    end

    it "full_messages_for does not contain error messages from other attributes" do
      person = Person.new
      person.errors.add(:name, "can not be blank")
      person.errors.add(:email, "can not be blank")
      person.errors.full_messages_for(:name).should eq(["name can not be blank"])
    end

    it "full_messages_for returns an empty list in case there are no errors for the given attribute" do
      person = Person.new
      person.errors.add(:name, "can not be blank")
      person.errors.full_messages_for(:email).should eq([])
    end

    it "full_message returns the given message when attribute is :base" do
      person = Person.new
      person.errors.full_message(:base, "press the button").should eq("press the button")
    end

    it "full_message returns the given message with the attribute name included" do
      person = Person.new
      person.errors.full_message(:name, "can not be blank").should eq("name can not be blank")
      person.errors.full_message(:name_test, "can not be blank").should eq("name_test can not be blank")
    end
  end
end
