require 'spec_helper'

class AcceptanceParams < SimpleParams::Params
  param :reference, type: :object, optional: true
  param :name
  param :age, type: :integer, optional: true, validations: { inclusion: { in: 18..100 } }
  param :color, default: "red", validations: { inclusion: { in: ["red", "green"] }}
  validate :name_has_letters

  nested_hash :address do
    param :street
    param :city, validations: { length: { in: 4..40 } }
    param :zip_code, optional: true
    param :state, default: "North Carolina"
    param :company, optional: true
  end

  def name_has_letters
    if name.present? && !(name =~ /^[a-zA-Z]*$/)
      errors.add(:name, "must only contain letters")
    end
  end
end

describe SimpleParams::Params do
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

  describe "nested_class", nested_class: true do
    it "names nested class correctly" do
      nested = AcceptanceParams.new.address
      name = nested.class.name
      name.should eq("AcceptanceParams::Address")
    end

    # it "names nested class model_class correctly" do
    #   nested = AcceptanceParams.new.address
    #   name = nested.model_class
    #   name.should eq("")
    # end
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

  describe "attributes", attributes: true do
    it "returns array of attribute symbols" do
      params = AcceptanceParams.new
      params.attributes.should eq([:reference, :name, :age, :color, :address])
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

    describe "nested params", nested: true do
      it "validates presence of required param" do
        params.should_not be_valid
        params.errors[:address][:street].should eq(["can't be blank"])
      end

      it "does not validate presence of optional param" do
        params.should_not be_valid
        params.errors[:address][:zip_code].should be_empty
      end
    end

    describe "#validate!" do
      let(:params) { AcceptanceParams.new }

      it "raises error with validation descriptions" do
        expect { params.validate! }.to raise_error(SimpleParamsError,
          "{:name=>[\"can't be blank\"], :address=>{:street=>[\"can't be blank\"], :city=>[\"is too short (minimum is 4 characters)\", \"can't be blank\"]}}"
        )
      end
    end

    describe "acceptance cases" do
      let(:params) do
        {
          name: "Tom", 
          age: 41,
          address: { 
            street: "1 Main St.",
            city: "Chicago",
            state: "IL",
            zip_code: 33440
          }
        }
      end

      it "is valid after multiple times" do
        acceptance_params = AcceptanceParams.new(params)
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
  end

  describe "api_pie_documentation", api_pie_documentation: true do
    it "generates valida api_pie documentation" do
      documentation = AcceptanceParams.api_pie_documentation
      api_docs = <<-API_PIE_DOCS
        param:reference, Object, desc:'', required: false
        param :name, String, desc: '', required: true
        param :age, Integer, desc: '', required: false
        param :color, String, desc: '', required: true
        param :address, Hash, desc: '', required: true do
          param :street, String, desc: '', required: true
          param :city, String, desc: '', required: true
          param :zip_code, String, desc: '', required: false
          param :state, String, desc: '', required: true
          param :company, String, desc: '', required: false
        end
      API_PIE_DOCS

      expect(documentation).to be_a String
      expect(documentation.gsub(/\s+/, "")).to eq api_docs.gsub(/\s+/, "")
    end
  end
end
