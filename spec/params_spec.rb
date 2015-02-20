require 'spec_helper'

class DummyParams < SimpleParams::Params
  string_param :name
  integer_param :age, optional: true
  date_param :birthdate, optional: true
  datetime_param :current_time, optional: true
  decimal_param :amount, optional: true
  float_param :fraction, optional: true
  param :color, default: "red", validations: { inclusion: { in: ["red", "green"] }}

  nested_hash :address do
    string_param :street
    string_param :city, validations: { length: { in: 4..40 } }
    string_param :zip_code, optional: true
    param :state, default: "North Carolina"
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
end