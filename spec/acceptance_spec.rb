require 'spec_helper'

class DummyParams < SimpleParams::Params
  required_param :name
  optional_param :age
  optional_param :color, default: "red", validations: { inclusion: { in: ["red", "green"] }}

  nested_param :address do
    required_param :street
    required_param :city, validations: { length: { in: 4..40 } }
    optional_param :zip_code
    optional_param :state, default: "North Carolina"
  end
end

describe SimpleParams::Params do
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
      params.name = 19
      params.name.should eq(19)
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

  describe "validations", validations: true do
    let(:params) { DummyParams.new }

    it "validates presence of required param" do
      params.should_not be_valid
      params.errors[:name].should eq(["can't be blank"])
    end

    it "does not validate presence of optional param" do
      params.should_not be_valid
      params.errors[:age].should be_empty
    end

    it "does validate other validations of optional param" do
      params = DummyParams.new(color: "blue")
      params.should_not be_valid
      params.errors[:color].should eq(["is not included in the list"])
    end

    describe "nested params", nested: true do
      it "validates presence of required param", failing: true do
        params.should_not be_valid
        params.errors[:address][:street].should eq(["can't be blank"])
      end

      it "does not validate presence of optional param" do
        params.should_not be_valid
        params.errors[:address][:zip_code].should be_empty
      end
    end
  end
end