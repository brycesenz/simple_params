require 'spec_helper'

describe SimpleParams::InitializationHash do
  let(:raw_params) do
    {
      "name" => "Emily",
      "age" => "28",
      "date_of_birth(3i)" => "30", 
      "date_of_birth(2i)" => "4", 
      "date_of_birth(1i)" => "1987",
      "current_time(6i)" => "56", 
      "current_time(5i)" => "11", 
      "current_time(4i)" => "9",
      "current_time(3i)" => "29", 
      "current_time(2i)" => "10", 
      "current_time(1i)" => "2015",
      "invalid_time(6i)" => "56", 
      "invalid_time(5i)" => nil, 
      "invalid_time(4i)" => "9",
      "invalid_time(3i)" => nil, 
      "invalid_time(2i)" => "10", 
      "invalid_time(1i)" => "2015"      
    }
  end

  let(:initialization_hash) do
    described_class.new(raw_params)
  end

  it "has correct original_params" do
    initialization_hash.original_params.should eq(
      :name => "Emily",
      :age => "28",
      :"date_of_birth(3i)" => "30", 
      :"date_of_birth(2i)" => "4", 
      :"date_of_birth(1i)" => "1987",
      :"current_time(6i)" => "56", 
      :"current_time(5i)" => "11", 
      :"current_time(4i)" => "9",
      :"current_time(3i)" => "29", 
      :"current_time(2i)" => "10", 
      :"current_time(1i)" => "2015",      
      :"invalid_time(6i)" => "56", 
      :"invalid_time(5i)" => nil, 
      :"invalid_time(4i)" => "9",
      :"invalid_time(3i)" => nil, 
      :"invalid_time(2i)" => "10", 
      :"invalid_time(1i)" => "2015"      
    )
  end

  it "has correct name" do
    initialization_hash[:name].should eq("Emily")
  end 

  it "has correct age" do
    initialization_hash[:age].should eq("28")
  end 

  it "has correct date_of_birth" do
    initialization_hash[:date_of_birth].should eq(Date.new(1987, 4, 30))
  end 

  it "has correct current_time" do
    initialization_hash[:current_time].should eq(Time.new(2015, 10, 29, 9, 11, 56))
  end 

  it "has nil invalid_time" do
    initialization_hash[:invalid_time].should eq(nil)
  end 
end
