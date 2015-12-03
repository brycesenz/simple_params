require 'spec_helper'

class AcceptanceParams < SimpleParams::Params
  with_rails_helpers
  allow_undefined_params
  param :reference, type: :object, optional: true
  param :name
  param :date_of_birth, type: :date, optional: true
  param :content, optional: true, validations: { length: {
    minimum: 20,
    maximum: 40,
    tokenizer: lambda { |str| str.split(/\s+/) },
    too_short: "must have at least %{count} words",
    too_long: "must have at most %{count} words"
  } }
  param :current_time, type: :datetime, optional: true
  param :age, type: :integer, optional: true, validations: { inclusion: { in: 18..100 } }
  param :color, default: "red", validations: { inclusion: { in: ["red", "green"] }}
  param :sibling_names, type: :array, optional: true
  validate :name_has_letters

  nested_hash :address do
    param :street
    param :city, validations: { length: { in: 4..40 } }
    param :zip_code, optional: true
    param :state, default: "North Carolina"
    param :company, optional: true
  end

  nested_hash :phone, optional: true do
    param :phone_number
  end

  nested_array :dogs do
    param :name
    param :age, type: :integer, validations: { inclusion: { in: 1..20 } }
  end

  nested_array :cats, with_ids: true do
    param :name
  end

  nested_array :birds, optional: true, with_ids: true do
    param :name
  end

  before_validation :set_current_time

  def set_current_time
    self.current_time ||= DateTime.new(2014, 3, 2, 10, 3, 4)
  end

  def name_has_letters
    if name.present? && !(name =~ /^[a-zA-Z]*$/)
      errors.add(:name, "must only contain letters")
    end
  end
end

describe SimpleParams::Params do
  describe "model_name", model_name: true do
    it "has an ActiveModel name" do
      params = AcceptanceParams.new
      params.class.model_name.should be_a(ActiveModel::Name)
      params.class.model_name.to_s.should eq("AcceptanceParams")
    end
  end

  describe "reflect_on_association", reflect_on_association: true do
    it "can get hash association classes" do
      klass = AcceptanceParams.reflect_on_association(:address).klass
      klass.should eq(AcceptanceParams::Address)
    end

    it "can get array association classes" do
      klass = AcceptanceParams.reflect_on_association(:dogs).klass
      klass.should eq(AcceptanceParams::Dogs)
    end
  end

  describe "rails_helpers", rails_helpers: true do
    it "can build optional class" do
      klass = AcceptanceParams.new.build_phone
      klass.should be_a(AcceptanceParams::Phone)
    end
  end

  describe "original_params", original_params: true do
    it "returns symbolized params hash" do
      params = AcceptanceParams.new(name: "Tom", address: { "street" => "1 Main St."} )
      params.original_params.should eq({
        name: "Tom", 
        address: { 
          street: "1 Main St."
        }
      })
    end

    it "returns symbolized params for nested_hash" do
      params = AcceptanceParams.new(name: "Tom", address: { "street" => "1 Main St."} )
      params.address.original_params.should eq({
        street: "1 Main St."
      })
    end
  end

  describe "to_hash", to_hash: true do
    it "returns params hash" do
      params = AcceptanceParams.new(
        name: "Tom", 
        address: { 
          "street" => "1 Main St."
        },
        dogs: [
          {
            name: "Spot",
            age: 8
          }
        ]
      )

      params.to_hash.should eq({
        reference: nil,
        name: "Tom", 
        date_of_birth: nil,
        content: nil,
        current_time: nil,
        age: nil,
        color: "red",
        sibling_names: nil,
        address: { 
          street: "1 Main St.",
          city: nil,
          zip_code: nil,
          state: "North Carolina",
          company: nil,
          _destroy: false
        },
        phone: nil,
        dogs: [
          {
            name: "Spot",
            age: 8,
            _destroy: false
          }
        ],
        cats: [
          {
            name: nil,
            _destroy: false
          }
        ],
        birds: [
        ]
      })
    end
  end

  describe "nested_class", nested_class: true do
    it "names nested class correctly" do
      nested = AcceptanceParams.new.address
      name = nested.class.name
      name.should eq("AcceptanceParams::Address")
    end

    it "has correct model_name" do
      nested = AcceptanceParams.new.address
      name = nested.class.model_name.to_s
      name.should eq("AcceptanceParams::Address")
    end

    it "names nested class model_class correctly" do
      nested = AcceptanceParams.new.address
      name = nested.class.name
      name.should eq("AcceptanceParams::Address")
    end

    describe "params assignment" do
      let(:params) do
        {
          dogs: [
            { name: "Max", age: 12 },
            { name: "Spot", age: 4 },
            { name: "Pants", age: 6, _destroy: true },
          ],
          cats: {
            "0" => { name: "Paws" },
            "1" => { name: "Turbo", _destroy: "1" },
            "2" => { name: "Felix" }
          },
          birds: {
            "0" => { name: "Birdy" },
            "1" => { name: "Tweety", _destroy: "1" }
          }
        }
      end

      subject { AcceptanceParams.new(params) }

      it "builds correct number of dogs" do
        subject.dogs.count.should eq(2)
      end

      it "builds correct number of cats" do
        subject.cats.count.should eq(2)
      end

      it "builds correct number of birds" do
        subject.birds.count.should eq(1)
      end
    end
  end

  describe "accessors", accessors: true do
    let(:params) { AcceptanceParams.new }

    it "has getter and setter methods for object param" do
      params.should respond_to(:reference)
      params.reference.should be_nil
      new_object = OpenStruct.new(count: 4)
      params.reference = new_object
      params.reference.should eq(new_object)
    end

    it "has getter and setter methods for required param" do
      params.should respond_to(:name)
      params.name.should be_nil
      params.name = "Tom"
      params.name.should eq("Tom")
    end

    it "has getter and setter methods for optional param" do
      params.should respond_to(:age)
      params.name.should be_nil
      params.age = 19
      params.age.should eq(19)
    end

    describe "nested params", nested: true do
      it "has getter and setter methods for required param" do
        params.address.should respond_to(:street)
        params.address.street.should be_nil
        params.address.street = "1 Main St."
        params.address.street.should eq("1 Main St.")
      end

      it "has getter and setter methods for optional param" do
        params.address.should respond_to(:zip_code)
        params.address.zip_code.should be_nil
        params.address.zip_code = "20165"
        params.address.zip_code.should eq("20165")
      end
    end
  end

  describe "datetime setters", datetime_accessors: true do
    it "can set date through Rails style date setters" do
      params = AcceptanceParams.new(
        "date_of_birth(3i)" => "5", 
        "date_of_birth(2i)" => "6", 
        "date_of_birth(1i)" => "1984"
      )
      params.date_of_birth.should eq(Date.new(1984, 6, 5))
    end

    it "can set datetime through Rails style date setters" do
      params = AcceptanceParams.new(
        "current_time(6i)" => "56", 
        "current_time(5i)" => "11", 
        "current_time(4i)" => "9",
        "current_time(3i)" => "29", 
        "current_time(2i)" => "10", 
        "current_time(1i)" => "2015"
      )
      params.current_time.should eq(DateTime.new(2015, 10, 29, 9, 11, 56, '-04:00'))
    end
  end

  describe "attributes", attributes: true do
    it "returns array of attribute symbols" do
      params = AcceptanceParams.new
      params.attributes.should eq([:reference, :name, :date_of_birth, :content, :current_time, :age, :color, :sibling_names, :address, :phone, :dogs, :cats, :birds])
    end

    it "returns array of attribute symbols for nested class" do
      params = AcceptanceParams::Address.new({}, nil, "address")
      params.parent_attribute_name.should eq(:address)
      params.attributes.should eq([:street, :city, :zip_code, :state, :company, :_destroy])
    end

    it "initializes attributes correctly" do
      params = AcceptanceParams.new
      attribute = params.instance_variable_get("@age_attribute")
      attribute.parent.should eq(params)
      attribute.name.should eq(:age)
      attribute.type.should eq(Integer)
      attribute.formatter.should be_nil
      attribute.validations.should eq({ inclusion: { in: 18..100 }, allow_nil: true })
    end
  end

  describe "array syntax", array_syntax: true do
    let(:params) do
      AcceptanceParams.new(
        name: "Bill",
        age: 30,
        address: {
          city: "Greenville"
        }
      )
    end

    it "can access 'name' through array syntax" do
      params[:name].should eq("Bill")
      params["name"].should eq("Bill")
    end

    it "can set 'name' through array syntax" do
      params[:name] = "Tom"
      params[:name].should eq("Tom")
      params["name"].should eq("Tom")
    end

    it "can access 'age' through array syntax" do
      params[:age].should eq(30)
      params["age"].should eq(30)
    end

    it "can set 'age' through array syntax" do
      params[:age] = 42
      params[:age].should eq(42)
      params["age"].should eq(42)
    end

    describe "nested params", nested: true do
      it "can access 'city' through array syntax" do
        params[:address][:city].should eq("Greenville")
        params["address"]["city"].should eq("Greenville")
      end

      it "can set 'city' through array syntax" do
        params[:address][:city] = "Asheville"
        params[:address][:city].should eq("Asheville")
        params["address"]["city"].should eq("Asheville")
      end
    end
  end

  describe "validations", validations: true do
    let(:params) { AcceptanceParams.new }

    it "validates presence of required param" do
      params.should_not be_valid
      params.errors[:name].should eq(["can't be blank"])
    end

    it "runs custom validate methods" do
      params.name = "!!!"
      params.should_not be_valid
      params.errors[:name].should eq(["must only contain letters"])
    end

    it "does not validate presence of optional param" do
      params.should_not be_valid
      params.errors[:age].should be_empty
    end

    it "does validate other validations of optional param" do
      params = AcceptanceParams.new(color: "blue")
      params.should_not be_valid
      params.errors[:color].should eq(["is not included in the list"])
    end

    it "calls before_validation" do
      params = AcceptanceParams.new(color: "blue")
      params.should_not be_valid
      params.current_time.should eq(DateTime.new(2014, 3, 2, 10, 3, 4))
    end

    describe "nested hashes", nested_hash: true do
      it "validates presence of required param" do
        params.should_not be_valid
        params.errors[:address][:street].should eq(["can't be blank"])
      end

      it "does not validate presence of optional param" do
        params.should_not be_valid
        params.errors[:address][:zip_code].should be_empty
      end
    end

    describe "nested arrays", nested_array: true do
      it "validates presence of required param" do
        params = AcceptanceParams.new(
          dogs: [
            { name: "Max", age: 11 },
            { name: "Spot" }
          ]
        )
        params.should_not be_valid
        params.errors[:dogs][1][:age].should eq(["is not included in the list", "can't be blank"])
      end

      it "initializes birds as nil" do
        params = AcceptanceParams.new
        params.birds.should be_empty
      end

      it "allows absense of optional params" do
        params = AcceptanceParams.new(
          name: "test",
          address: {
            street: "1 Main St.",
            city: "Asheville",
            zip_code: "28806"
          },
          dogs: [
            { name: "spot", age: 13 }
          ],
          cats: {
            "0" => {
              name: "Purr"
            }
          },
        )
        params.birds.should be_empty
        params.should be_valid
      end
    end

    describe "#validate!" do
      let(:params) { AcceptanceParams.new }

      it "raises error with validation descriptions" do
        expect { params.validate! }.to raise_error(SimpleParamsError,
          "{:name=>[\"can't be blank\"], :address=>{:street=>[\"can't be blank\"], :city=>[\"is too short (minimum is 4 characters)\", \"can't be blank\"]}, :dogs=>[{:name=>[\"can't be blank\"], :age=>[\"is not included in the list\", \"can't be blank\"]}], :cats=>[{:name=>[\"can't be blank\"]}]}"
        )
      end
    end

    describe "acceptance cases" do
      context "without phone" do
        let(:params) do
          {
            name: "Tom", 
            age: 41,
            address: { 
              street: "1 Main St.",
              city: "Chicago",
              state: "IL",
              zip_code: 33440
            },
            dogs: [
              name: "Spot",
              age: 6
            ],
            cats: {
              "0" => {
                name: "Fuzzball"
              }
            }
          }
        end

        it "is valid after multiple times" do
          acceptance_params = AcceptanceParams.new(params)
          acceptance_params.valid?
          acceptance_params.should be_valid
          acceptance_params.errors.should be_empty
          acceptance_params.should be_valid
          acceptance_params.errors.should be_empty
        end

        it "is invalidated if validity changes after initial assignment" do
          acceptance_params = AcceptanceParams.new(params)
          acceptance_params.should be_valid
          acceptance_params.name = nil
          acceptance_params.should_not be_valid
        end
      end

      context "with phone" do
        let(:params) do
          {
            name: "Tom", 
            age: 41,
            address: { 
              street: "1 Main St.",
              city: "Chicago",
              state: "IL",
              zip_code: 33440
            },
            phone: {
              phone_number: "234"
            },
            dogs: [
              {
                name: "Spot",
                age: 6
              }
            ],
            cats: {
              "0" => {
                name: "Fuzzball"
              }
            }
          }
        end

        it "is valid after multiple times" do
          acceptance_params = AcceptanceParams.new(params)
          acceptance_params.valid?
          acceptance_params.should be_valid
          acceptance_params.should be_valid
        end

        it "is invalidated if validity changes after initial assignment" do
          acceptance_params = AcceptanceParams.new(params)
          acceptance_params.should be_valid
          acceptance_params.name = nil
          acceptance_params.should_not be_valid
        end
      end

      context "with destroyed dog" do
        let(:params) do
          {
            name: "Tom", 
            age: 41,
            address: { 
              street: "1 Main St.",
              city: "Chicago",
              state: "IL",
              zip_code: 33440
            },
            phone: {
              phone_number: "234"
            },
            dogs: [
              {
                name: "Spot",
                age: 6
              },
              {
                name: "Max",
                age: 4,
                _destroy: true
              }
            ],
            cats: {
              "0" => {
                name: "Fuzzball"
              }
            }
          }
        end

        it "is valid after multiple times" do
          acceptance_params = AcceptanceParams.new(params)
          acceptance_params.valid?
          acceptance_params.should be_valid
          acceptance_params.should be_valid
        end

        it "only assigns 1 dog" do
          acceptance_params = AcceptanceParams.new(params)
          acceptance_params.dogs.count.should eq(1)
        end
      end

      context "with destroyed cat" do
        let(:params) do
          {
            name: "Tom", 
            age: 41,
            address: { 
              street: "1 Main St.",
              city: "Chicago",
              state: "IL",
              zip_code: 33440
            },
            phone: {
              phone_number: "234"
            },
            dogs: [
              {
                name: "Spot",
                age: 6
              }
            ],
            cats: {
              "0" => {
                name: "Fuzzball"
              },
              "1" => {
                name: "Fuzzball 2",
                _destroy: "1"
              }
            }
          }
        end

        it "is valid after multiple times" do
          acceptance_params = AcceptanceParams.new(params)
          acceptance_params.valid?
          acceptance_params.should be_valid
          acceptance_params.should be_valid
        end

        it "only assigns 1 cat" do
          acceptance_params = AcceptanceParams.new(params)
          acceptance_params.cats.count.should eq(1)
        end
      end
    end
  end

  describe "anonymous params", anonymous_params: true do
    it "accepts anonymous params with simple values" do
      params = AcceptanceParams.new(random: "some_other_value")
      params.random.should eq("some_other_value")
    end

    it "accepts anonymous params hashes and creates Params class" do
      params = AcceptanceParams.new(random: { a: "1", b: "2"})
      params.random.should be_a(SimpleParams::Params)
      params.random.a.should eq("1")
      params.random.b.should eq("2")
    end

    it "accepts anonymous params hashes and names class correctly" do
      params = AcceptanceParams.new(random: { a: "1", b: "2"})
      params.random.class.name.to_s.should eq("AcceptanceParams::Random")
      params.random.class.model_name.to_s.should eq("AcceptanceParams::Random")
    end
  end

  describe "api_pie_documentation", api_pie_documentation: true do
    it "generates valida api_pie documentation" do
      documentation = AcceptanceParams.api_pie_documentation
      api_docs = <<-API_PIE_DOCS
        param:reference, Object, desc:'', required: false
        param :name, String, desc: '', required: true
        param :date_of_birth, Date, desc: '', required: false
        param:content,String,desc:'',required:false
        param :current_time, desc: '', required: false
        param :age, Integer, desc: '', required: false
        param :color, String, desc: '', required: false
        param :sibling_names, Array, desc: '', required: false
        param :address, Hash, desc: '', required: true do
          param :street, String, desc: '', required: true
          param :city, String, desc: '', required: true
          param :zip_code, String, desc: '', required: false
          param :state, String, desc: '', required: false
          param :company, String, desc: '', required: false
          param :_destroy, Boolean, desc:'', required: false
        end
        param :phone, Hash, desc: '', required: false do
          param :phone_number, String, desc: '', required: true
          param :_destroy, Boolean, desc:'', required: false
        end
        param :dogs, Array, desc: '', required: true do
          param :name, String, desc: '', required: true
          param :age, Integer, desc: '', required: true
          param :_destroy, Boolean, desc:'', required: false
        end
        param :cats, Array, desc:'', required: true do
          param :name, String, desc:'', required: true
          param :_destroy, Boolean, desc:'', required: false
        end
        param :birds, Array, desc:'', required: false do
          param :name, String, desc:'', required: true
          param :_destroy, Boolean, desc:'', required: false
        end
      API_PIE_DOCS

      expect(documentation).to be_a String
      expect(documentation.gsub(/\s+/, "")).to eq api_docs.gsub(/\s+/, "")
    end
  end
end
