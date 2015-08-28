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

  describe "setting and getting errors", setters_getters: true do
    it "get returns the errors for the provided key" do
      errors = SimpleParams::Errors.new(self)
      errors[:foo] = "omg"
      errors.get(:foo).should eq(["omg"])
    end

    it "sets the error with the provided key" do
      errors = SimpleParams::Errors.new(self)
      errors.set(:foo, "omg")
      errors.messages.should eq({ foo: "omg" })
    end

    it "values returns an array of messages" do
      errors = SimpleParams::Errors.new(self)
      errors.set(:foo, "omg")
      errors.set(:baz, "zomg")
      errors.values.should eq(["omg", "zomg"])
    end

    it "keys returns the error keys" do
      errors = SimpleParams::Errors.new(self)
      errors.set(:foo, "omg")
      errors.set(:baz, "zomg")
      errors.keys.should eq([:foo, :baz])
    end    

    describe "setting on model" do
      it "assign error" do
        person = Person.new
        person.errors[:name] = 'should not be nil'
        person.errors[:name].should eq(["should not be nil"])
      end

      it "add an error message on a specific attribute" do
        person = Person.new
        person.errors.add(:name, "can not be blank")
        person.errors[:name].should eq(["can not be blank"])
      end

      it "add an error with a symbol" do
        person = Person.new
        person.errors.add(:name, :blank)
        message = person.errors.generate_message(:name, :blank)
        person.errors[:name].should eq([message])
      end

      it "add an error with a proc" do
        person = Person.new
        message = Proc.new { "can not be blank" }
        person.errors.add(:name, message)
        person.errors[:name].should eq(["can not be blank"])
      end
    end
  end

  describe "setting and getting nested error model", nested_model: true do
    it "can access error model" do
      person = Person.new
      dog = person.dog
      dog_errors = dog.errors
      person.errors[:dog].should eq(dog_errors)
    end

    it "can add to nested errors through []" do
      person = Person.new
      person.errors[:dog] = 'should not be nil'
      person.dog.errors[:base].should eq(['should not be nil'])
    end

    it "can add to nested errors through add" do
      person = Person.new
      person.errors.add(:dog, 'should not be nil')
      person.dog.errors[:base].should eq(['should not be nil'])
    end

    it "can add multiple errors to nested errors through []" do
      person = Person.new
      person.errors[:dog] = 'should not be nil'
      person.errors[:dog] = 'must be cute'
      person.dog.errors[:base].should eq(['should not be nil', 'must be cute'])
    end

    it "can add multiple errors to nested errors through add" do
      person = Person.new
      person.errors.add(:dog, 'should not be nil')
      person.errors.add(:dog, 'must be cute')
      person.dog.errors[:base].should eq(['should not be nil', 'must be cute'])
    end

    it "can add individual errors to nested attributes through []" do
      person = Person.new
      person.errors[:dog][:breed] = 'should not be nil'
      person.dog.errors[:breed].should eq(['should not be nil'])
    end

    it "can add individual errors to nested attributes through  add" do
      person = Person.new
      person.errors[:dog].add(:breed, 'should not be nil')
      person.dog.errors[:breed].should eq(['should not be nil'])
    end
  end

  describe "setting and getting nested array error model", nested_array: true do
    it "can access error model" do
      person = Person.new
      cats = person.cats
      cat_errors = cats.first.errors
      person.errors[:cats][0].should eq(cat_errors)
    end

    it "can add to nested errors through []", failing: true do
      person = Person.new
      person.errors[:cats].first[:base] = 'should not be nil' 
      person.errors[:cats].first[:base].should eq(['should not be nil']) 
      person.cats.first.errors[:base].should eq(['should not be nil'])
    end

    it "can add to nested errors through add" do
      person = Person.new
      person.errors[:cats].first.add(:age, 'should not be nil')
      person.cats.first.errors[:age].should eq(['should not be nil'])
    end

    it "can add multiple errors to nested errors through []" do
      person = Person.new
      person.errors[:cats].first[:name] = 'should not be nil'
      person.errors[:cats].first[:name] = 'must be cute'
      person.cats.first.errors[:name].should eq(['should not be nil', 'must be cute'])
    end

    it "can add multiple errors to nested errors through add" do
      person = Person.new
      person.errors[:cats].first.add(:name, 'should not be nil')
      person.errors[:cats].first.add(:name, 'must be cute')
      person.cats.first.errors[:name].should eq(['should not be nil', 'must be cute'])
    end

    it "can add individual errors to nested attributes through []" do
      person = Person.new
      person.errors[:cats][0][:age] = 'should not be nil'
      person.cats.first.errors[:age].should eq(['should not be nil'])
    end

    it "can add individual errors to nested attributes through add" do
      person = Person.new
      person.errors[:cats].first.add(:age, 'should not be nil')
      person.cats.first.errors[:age].should eq(['should not be nil'])
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

  describe "#added?", added: true do
    it "added? detects if a specific error was added to the object" do
      person = Person.new
      person.errors.add(:name, "can not be blank")
      person.errors.added?(:name, "can not be blank").should be_truthy
    end

    it "added? handles symbol message" do
      person = Person.new
      person.errors.add(:name, :blank)
      person.errors.added?(:name, :blank).should be_truthy
    end

    it "added? handles proc messages" do
      person = Person.new
      message = Proc.new { "can not be blank" }
      person.errors.add(:name, message)
      person.errors.added?(:name, message).should be_truthy
    end

    it "added? defaults message to :invalid" do
      person = Person.new
      person.errors.add(:name)
      person.errors.added?(:name).should be_truthy
    end

    it "added? matches the given message when several errors are present for the same attribute" do
      person = Person.new
      person.errors.add(:name, "can not be blank")
      person.errors.add(:name, "is invalid")
      person.errors.added?(:name, "can not be blank").should be_truthy
    end

    it "added? returns false when no errors are present" do
      person = Person.new
      person.errors.added?(:name).should_not be_truthy
    end

    it "added? returns false when checking a nonexisting error and other errors are present for the given attribute" do
      person = Person.new
      person.errors.add(:name, "is invalid")
      person.errors.added?(:name, "can not be blank").should_not be_truthy
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
    it "to_hash returns the error messages hash", hash_failing: true do
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

  describe "#generate_message", generate_message: true do
    it "generate_message works without i18n_scope" do
      person = Person.new
      Person.should_not respond_to(:i18n_scope)
      expect {
        person.errors.generate_message(:name, :blank)
      }.to_not raise_error
    end
  end

  describe "#adds_on_empty", add_on_empty: true do
    it "add_on_empty generates message" do
      person = Person.new
      person.errors.should_receive(:generate_message).with(:name, :empty, {})
      person.errors.add_on_empty :name
    end

    it "add_on_empty generates message for multiple attributes" do
      person = Person.new
      person.errors.should_receive(:generate_message).with(:name, :empty, {})
      person.errors.should_receive(:generate_message).with(:age, :empty, {})
      person.errors.add_on_empty [:name, :age]
    end

    it "add_on_empty generates message with custom default message" do
      person = Person.new
      person.errors.should_receive(:generate_message).with(:name, :empty, { message: 'custom' })
      person.errors.add_on_empty :name, message: 'custom'
    end

    it "add_on_empty generates message with empty string value" do
      person = Person.new
      person.name = ''
      person.errors.should_receive(:generate_message).with(:name, :empty, {})
      person.errors.add_on_empty :name
    end
  end

  describe "#adds_on_blank", add_on_blank: true do
    it "add_on_blank generates message" do
      person = Person.new
      person.errors.should_receive(:generate_message).with(:name, :blank, {})
      person.errors.add_on_blank :name
    end

    it "add_on_blank generates message for multiple attributes" do
      person = Person.new
      person.errors.should_receive(:generate_message).with(:name, :blank, {})
      person.errors.should_receive(:generate_message).with(:age, :blank, {})
      person.errors.add_on_blank [:name, :age]
    end

    it "add_on_blank generates message with custom default message" do
      person = Person.new
      person.errors.should_receive(:generate_message).with(:name, :blank, { message: 'custom' })
      person.errors.add_on_blank :name, message: 'custom'
    end
  end
end
