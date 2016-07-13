require 'spec_helper'
require 'fixtures/dummy_params'

describe SimpleParams::Params do
  describe "strict parameter enforcement", param_enforcement: true do
    context "with default handling (strict enforcement)" do
      it "raises error on expected param" do
        expect { DummyParams.new(other_param: 1) }.to raise_error(SimpleParamsError)
      end
    end

    context "with strict enforcement" do
      before(:each) do
        DummyParams.strict
      end

      it "raises error on expected param" do
        expect { DummyParams.new(other_param: 1) }.to raise_error(SimpleParamsError)
      end
    end

    context "with allow_undefined_params" do
      before(:each) do
        DummyParams.allow_undefined_params
      end

      it "does not raises error on expected param" do
        expect { DummyParams.new(other_param: 1) }.to_not raise_error
      end

      it "can access original value through accessor" do
        model = DummyParams.new(other_param: 1)
        model.other_param.should eq(1)
      end
    end
  end

  describe "accessors", accessors: true do
    let(:params) { DummyParams.new }

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

      it "can set nested_array with hash" do
        params.address= { street: "2 Oak Ave.", city: "Miami", zip_code: "90210" }
        params.address.street.should eq("2 Oak Ave.")
        params.address.city.should eq("Miami")
        params.address.zip_code.should eq("90210")
      end
    end

    describe "nested arrays", nested: true do
      it "can access nested arrays as arrays" do
        params.dogs[0].should_not be_nil
        params.dogs[0].name.should be_nil
        params.dogs[0].age.should be_nil
      end

      it "can access nested arrays as arrays with data" do
        params = DummyParams.new(dogs: [{ name: "Spot", age: 20 }])
        params.dogs[0].name.should eq("SPOT")
      end

      it "can set nested arrays with arrays" do
        params.dogs = [{ name: "Spot", age: 20 }]
        params.dogs.count.should eq(1)
        params.dogs[0].name.should eq("SPOT")
        params.dogs[0].age.should eq(20)
      end
    end
  end

  describe "raw_values", raw_values: true do
    let(:params) { DummyParams.new(dogs: [{}]) }

    it "can access raw values for non-formatted param" do
      params.name = "Tom"
      params.name.should eq("Tom")
      params.raw_name.should eq("Tom")
    end

    it "can access raw values for formatted param" do
      params.amount = 1.095
      params.amount.should eq(1.10)
      params.raw_amount.should eq(1.095)
    end

    describe "nested params", nested: true do
      it "can access raw values for formatted param" do
        params.address.state = "SC"
        params.address.state.should eq("South Carolina")
        params.address.raw_state.should eq("SC")
      end
    end

    describe "nested arrays", nested: true do
      it "can access raw values for formatted param" do
        params.dogs.first.name = "Fido"
        params.dogs.first.name.should eq("FIDO")
        params.dogs.first.raw_name.should eq("Fido")
      end
    end
  end

  describe "attributes", attributes: true do
    it "returns array of attribute symbols" do
      params = DummyParams.new
      params.attributes.should eq([:name, :age, :first_initial, :amount, :color, :height, :address, :phone, :dogs])
    end
  end

  describe "array syntax", array_syntax: true do
    let(:params) do
      DummyParams.new(
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
    context "with multiple invalid params" do
      let(:params) do
        DummyParams.new(
          name: nil,
          age: 30,
          address: {
            city: "Greenville"
          },
          dogs: [
            { name: "Spot", age: 12 },
            { age: 14 }
          ]
        )
      end

      it "validates required params" do
        params.should_not be_valid
        params.errors[:name].should eq(["can't be blank"])
      end

      it "validates nested params" do
        params.should_not be_valid
        params.address.errors[:street].should eq(["can't be blank"])
        params.errors[:address][:street].should eq(["can't be blank"])
        params.errors[:address][:zip_code].should eq(["is too short (minimum is 5 characters)", "can't be blank"])
      end

      it "validates nested arrays" do
        params.should_not be_valid
        params.errors[:dogs][0][:name].should eq([])
        params.errors[:dogs][1][:name].should eq(["can't be blank"])
      end
    end

    context "with only invalid nested array", fail: true do
      let(:params) do
        DummyParams.new(
          name: "Bill",
          age: 30,
          address: {
            street: "1 Main St.",
            city: "Greenville"
          },
          phone: {
            phone_number: "8085551212"
          },
          dogs: [
            { name: "Spot", age: 12 },
            { age: 14 }
          ]
        )
      end

      it "validates nested arrays" do
        params.should_not be_valid
        params.errors[:dogs][0][:name].should eq([])
        params.errors[:dogs][1][:name].should eq(["can't be blank"])
      end
    end
  end

  describe "optional params with inclusion", optional_params: true do
    let(:params) do
      DummyParams.new(
        name: "Bill",
        age: 30,
        address: {
          city: "Greenville"
        }
      )
    end

    it "allows optional params to be nil with inclusion" do
      params.should_not be_valid
      params.errors[:height].should be_empty
    end
  end

  describe "coercion", coercion: true do
    it "coerces values on initialization" do
      params = DummyParams.new(age: "42")
      params.age.should eq(42)
    end

    it "coerces values from setters" do
      params = DummyParams.new
      params.age = "42"
      params.age.should eq(42)
    end

    it "coerces nested attributes on initialization" do
      params = DummyParams.new(address: { zip_code: 90210 })
      params.address.zip_code.should eq("90210")
    end

    it "coerces nested attributes from setters" do
      params = DummyParams.new
      params.address.zip_code = 90210
      params.address.zip_code.should eq("90210")
    end
  end

  describe "defaults", defaults: true do
    describe "simple defaults" do
      it "sets default values on initialization without key" do
        params = DummyParams.new
        params.amount.should eq(0.10)
      end

      it "sets default values on initialization with nil value" do
        params = DummyParams.new(amount: nil)
        params.amount.should eq(0.10)
      end

      it "sets default values on initialization with blank value" do
        params = DummyParams.new(amount: "")
        params.amount.should eq(0.10)
      end

      describe "nested params" do
        it "sets default values on initialization without key" do
          params = DummyParams.new
          params.phone.cell_phone.should be_truthy
        end

        it "sets default values on initialization with nil value" do
          params = DummyParams.new(phone: { cell_phone: nil })
          params.phone.cell_phone.should be_truthy
        end

        it "sets default values on initialization with blank value" do
          params = DummyParams.new(phone: { cell_phone: "" })
          params.phone.cell_phone.should be_truthy
        end
      end
    end

    describe "Proc defaults" do
      it "sets default values on initialization without key" do
        params = DummyParams.new
        params.first_initial.should be_nil
        params = DummyParams.new(name: "Tom")
        params.first_initial.should eq("T")
      end

      it "sets default values on initialization with nil value" do
        params = DummyParams.new
        params.first_initial.should be_nil
        params = DummyParams.new(name: "Tom", first_initial: nil)
        params.first_initial.should eq("T")
      end

      it "sets default values on initialization with blank value" do
        params = DummyParams.new
        params.first_initial.should be_nil
        params = DummyParams.new(name: "Tom", first_initial: "")
        params.first_initial.should eq("T")
      end

      describe "nested params" do
        it "sets default values on initialization without key" do
          params = DummyParams.new
          params.phone.area_code.should be_nil
          params = DummyParams.new(phone: { phone_number: "8185559988" })
          params.phone.area_code.should eq("818")
        end

        it "sets default values on initialization with nil value" do
          params = DummyParams.new
          params.phone.area_code.should be_nil
          params = DummyParams.new(phone: { phone_number: "8185559988", area_code: nil })
          params.phone.area_code.should eq("818")
        end

        it "sets default values on initialization with blank value" do
          params = DummyParams.new
          params.phone.area_code.should be_nil
          params = DummyParams.new(phone: { phone_number: "8185559988", area_code: "" })
          params.phone.area_code.should eq("818")
        end
      end
    end
  end

  describe "formatters", formatters: true do
    describe "Proc formatters" do
      it "formats on initialization" do
        params = DummyParams.new(amount: 0.1234)
        params.amount.should eq(0.12)
      end

      describe "nested params" do
        it "formats on initialization" do
          params = DummyParams.new(phone: { phone_number: "818-555-9988" })
          params.phone.phone_number.should eq("8185559988")
        end
      end
    end

    describe "method formatters" do
      it "formats on initialization" do
        params = DummyParams.new(color: "BLUE")
        params.color.should eq("blue")
      end

      describe "nested params" do
        it "formats on initialization" do
          params = DummyParams.new(address: { state: "SC" })
          params.address.state.should eq("South Carolina")
        end
      end
    end
  end

  describe "undefined params", undefined_params: true do
    before(:each) do
      DummyParams.allow_undefined_params
    end

    it "allows undefined params, and responds with their values" do
      model = DummyParams.new(other_param: 1)
      model.other_param.should eq(1)
    end

    describe "nested params" do
      it "allows undefined nested params, and creates an anonymous Params class for them" do
        model = DummyParams.new(nested: { some_value: 1 } )
        model.nested.should be_a(SimpleParams::Params)
      end

      it "allows undefined nested params, and name class correctly" do
        model = DummyParams.new(nested: { some_value: 1 } )
        model.nested.class.name.should eq("DummyParams::Nested")
      end

      it "allows accessors for nested attributes" do
        model = DummyParams.new(nested: { some_value: 1 } )
        model.nested.some_value.should eq(1)
      end

      it "allows multilevel nested params, and creates an anonymous Params class for them" do
        model = DummyParams.new(nested: { other_nested: { some_value: 1 } } )
        model.nested.other_nested.should be_a(SimpleParams::Params)
        model.nested.other_nested.some_value.should eq(1)
      end
    end
  end

  describe "api_pie_documentation", api_pie_documentation: true do
    it "generates valid api_pie documentation" do
      documentation = DummyParams.api_pie_documentation
      api_docs = <<-API_PIE_DOCS
                  param :name, String, desc: '', required: true
                  param :age, Integer, desc: '', required: false
                  param :first_initial, String, desc: '', required: false
                  param :amount, desc: '', required: false
                  param :color, String, desc: '', required: false
                  param :height, String, desc: '', required: false
                  param :address, Hash, desc: '', required: true do
                    param :street, String, desc: '', required: true
                    param :city, String, desc: '', required: true
                    param :zip_code, String, desc: '', required: true
                    param :state, String, desc: '', required: false
                  end
                  param :phone, Hash, desc: '', required: true do
                    param :cell_phone, Boolean, desc: '', required: false
                    param :phone_number, String, desc: '', required: true
                    param :area_code, String, desc: '', required: false
                  end
                  param :dogs, Array, desc: '', required: true do
                    param :name, String, desc: '', required: true
                    param :age, Integer, desc: '', required: true
                  end
                API_PIE_DOCS

      expect(documentation).to be_a String
      expect(documentation.gsub(/\s+/, "")).to eq api_docs.gsub(/\s+/, "")
    end
  end
end
