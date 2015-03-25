require 'spec_helper'

class DummyParams < SimpleParams::Params
  string_param :name
  integer_param :age, optional: true
  string_param :first_initial, default: lambda { |params, param| params.name[0] if params.name.present? }
  decimal_param :amount, optional: true, default: 0.10, formatter: lambda { |params, param| param.round(2) }
  param :color, default: "red", validations: { inclusion: { in: ["red", "green"] }}, formatter: :lower_case_colors

  nested_hash :address do
    string_param :street
    string_param :city, validations: { length: { in: 4..40 } }
    string_param :zip_code, optional: true, validations: { length: { in: 5..9 } }
    param :state, default: "North Carolina", formatter: :transform_state_code

    def transform_state_code(val)
      val == "SC" ? "South Carolina" : val
    end
  end

  nested_hash :phone do
    boolean_param :cell_phone, default: true
    string_param :phone_number, validations: { length: { in: 7..10 } }, formatter: lambda { |params, attribute| attribute.gsub(/\D/, "") }
    string_param :area_code, default: lambda { |params, param|
      if params.phone_number.present?
        params.phone_number[0..2]
      end
    }
  end

  def lower_case_colors(val)
    val.downcase
  end
end

describe SimpleParams::Params do
  describe "strict parameter enforcement" do
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

  describe "api_pie_documentation" do
    it "generates valida api_pie documentation" do
      documentation = DummyParams.api_pie_documentation
      api_docs = <<-API_PIE_DOCS
                  param :name, String, required: true
                  param :age, Integer
                  param :first_initial, String, required: true
                  param :amount
                  param :color, String, required: true
                  param :address, Hash, required: true do
                    param :street, String, required: true
                    param :city, String, required: true
                    param :zip_code, String
                    param :state, String, required: true
                  end
                  param :phone, Hash, required: true do
                    param :cell_phone, required: true
                    param :phone_number, String, required: true
                    param :area_code, String, required: true
                  end
                API_PIE_DOCS

      expect(documentation).to be_a String
      expect(documentation.gsub(/\s+/, "")).to eq api_docs.gsub(/\s+/, "")
    end
  end
end
