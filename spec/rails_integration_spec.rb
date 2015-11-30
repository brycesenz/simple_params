require 'spec_helper'

class RailsIntegrationParams < SimpleParams::Params
  with_rails_helpers
  
  param :name
  param :age, type: :integer, optional: true, validations: { inclusion: { in: 18..100 } }
  param :current_time, type: :datetime, optional: true

  nested_hash :address do
    param :street
    param :city, validations: { length: { in: 4..40 } }
    param :zip_code, optional: true
    param :state, default: "North Carolina"
  end

  nested_array :dogs, with_ids: true do
    param :name
    param :age, type: :integer, validations: { inclusion: { in: 1..20 } }
  end
end

describe SimpleParams::Params do
  context "with valid params" do
    let!(:params) do
      RailsIntegrationParams.new(
        name: "Tom",
        age: 21,
        "current_time(6i)" => 59,
        "current_time(5i)" => 58,
        "current_time(4i)" => 11,
        "current_time(3i)" => 4,
        "current_time(2i)" => 3,
        "current_time(1i)" => 2009,
        address_attributes: {
          street: "1 Main St.",
          city: "Charlotte"
        },
        dogs_attributes: {
          "0" => {
            name: "Spot",
            age: 4
          },
          "1" => {
            age: 6
          }
        }
      )
    end

    specify "setting datetime" do
      expect(params.current_time).to eq DateTime.new(2009, 3, 4, 11, 58, 59, '-05:00')
    end

    specify "sets address" do
      address = params.address
      expect(address.street).to eq "1 Main St."
      expect(address.city).to eq "Charlotte"
    end

    specify "sets dogs"do
      dogs = params.dogs
      expect(dogs.count).to eq 2
      expect(dogs[0].name).to eq "Spot"
      expect(dogs[0].age).to eq 4
      expect(dogs[1].name).to eq nil
      expect(dogs[1].age).to eq 6
    end
  end

  context "with invalid datetime params" do
    let!(:params) do
      RailsIntegrationParams.new(
        name: "Tom",
        age: 21,
        "current_time(6i)" => nil,
        "current_time(5i)" => nil,
        "current_time(4i)" => nil,
        "current_time(3i)" => 1,
        "current_time(2i)" => nil,
        "current_time(1i)" => nil,
        address_attributes: {
          street: "1 Main St.",
          city: "Charlotte"
        },
        dogs_attributes: {
          "0" => {
            name: "Spot",
            age: 4
          },
          "1" => {
            age: 6
          }
        }
      )
    end

    specify "setting datetime to nil" do
      expect(params.current_time).to eq(nil)
    end
  end
end
