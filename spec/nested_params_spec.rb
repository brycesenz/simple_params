require 'spec_helper'
require 'fixtures/dummy_params'

describe SimpleParams::NestedParams do
  # Turn off Constant Redefined errors
  before(:each) do
    $VERBOSE = nil
  end

  class DummyParentClass < SimpleParams::Params
  end

  describe "class_methods", class_methods: true do
    let!(:parent) { DummyParentClass }
    let!(:name) { :my_special_params }

    describe "define_new_hash_class", define_new_hash_class: true do
      let(:options) do
        {
          first_option: "yes",
          second_option: "totally"
        }
      end

      let(:defined_class) do
        described_class.define_new_hash_class(parent, name, options) do
          param :name, default: "Tom"
          param :age
        end
      end

      it "has correct name" do
        defined_class.name.should eq("DummyParentClass::MySpecialParams")
      end

      it "has correct options" do
        defined_class.options.should eq(
          {
            first_option: "yes", 
            second_option: "totally",
            type: :hash
          }
        )
      end

      it "has correct type" do
        defined_class.type.should eq(:hash)
      end

      it "does not use ids" do
        defined_class.with_ids?.should eq(false)
      end
    end

    describe "define_new_array_class", define_new_array_class: true do
      let(:options) do
        {
          first_option: "yes",
          second_option: "totally",
          with_ids: true
        }
      end

      let(:defined_class) do
        described_class.define_new_array_class(parent, name, options) do
          param :name, default: "Tom"
          param :age
        end
      end

      it "has correct name" do
        defined_class.name.should eq("DummyParentClass::MySpecialParams")
      end

      it "has correct options" do
        defined_class.options.should eq(
          {
            first_option: "yes", 
            second_option: "totally",
            with_ids: true,
            type: :array
          }
        )
      end

      it "has correct type" do
        defined_class.type.should eq(:array)
      end

      it "doe use ids" do
        defined_class.with_ids?.should eq(true)
      end
    end
  end

  describe "initialization" do
    context "with hash class" do
      context "without ids" do
        let(:defined_class) do
          described_class.define_new_hash_class(DummyParentClass, :demo, {}) do
            param :name, default: "Tom"
            param :age, type: :integer
          end
        end

        subject { defined_class.new(name: "Bill", age: 21) }
        
        specify "name" do
          expect(subject.name).to eq "Bill"
        end

        specify "age" do
          expect(subject.age).to eq 21
        end

        specify "id" do
          expect(subject.id).to eq nil
        end
      end

      context "with ids" do
        let(:defined_class) do
          described_class.define_new_hash_class(DummyParentClass, :demo, { with_ids: true }) do
            param :name, default: "Tom"
            param :age, type: :integer
          end
        end

        subject { defined_class.new("132" => { name: "Bill", age: 21 }) }
        
        specify "name" do
          expect(subject.name).to eq "Bill"
        end

        specify "age" do
          expect(subject.age).to eq 21
        end

        specify "id" do
          expect(subject.id).to eq "132"
        end
      end
    end

    context "with array class" do
      context "without ids" do
        let(:defined_class) do
          described_class.define_new_array_class(DummyParentClass, :demo, {}) do
            param :name, default: "Tom"
            param :age, type: :integer
          end
        end

        subject { defined_class.new(name: "Bill", age: 21) }
        
        specify "name" do
          expect(subject.name).to eq "Bill"
        end

        specify "age" do
          expect(subject.age).to eq 21
        end

        specify "id" do
          expect(subject.id).to eq nil
        end
      end

      context "with ids" do
        let(:defined_class) do
          described_class.define_new_array_class(DummyParentClass, :demo, { with_ids: true }) do
            param :name, default: "Tom"
            param :age, type: :integer
          end
        end

        subject { defined_class.new("132" => { name: "Bill", age: 21 }) }
        
        specify "name" do
          expect(subject.name).to eq "Bill"
        end

        specify "age" do
          expect(subject.age).to eq 21
        end

        specify "id" do
          expect(subject.id).to eq "132"
        end
      end
    end
  end
end
