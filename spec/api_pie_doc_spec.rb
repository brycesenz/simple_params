require 'spec_helper'

describe SimpleParams::ApiPieDoc do

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

  let(:api_pie_doc) { SimpleParams::ApiPieDoc.new(DummyParams) }

  describe "#initialize" do
    specify "should give object base_attributes" do
      expect(api_pie_doc.base_attributes).to include(name: { type: :string })
      expect(api_pie_doc.base_attributes).to include(age: { optional: true, type: :integer })
      expect(api_pie_doc.base_attributes.keys).to include(:amount, :color, :first_initial)
    end

    specify "should give object nested_hashes" do
      expect(api_pie_doc.nested_hashes.keys).to eq [:address, :phone]
    end

    specify "should call #build_nested_attributes" do
      expect_any_instance_of(SimpleParams::ApiPieDoc).to receive(:build_nested_attributes)
      api_pie_doc
    end

    specify "should give object nested_attributes" do
      expect(api_pie_doc.nested_attributes.flat_map(&:keys)).to eq [:address, :phone]
      expect(api_pie_doc.nested_attributes[0].values.flat_map(&:keys)).to eq [:street, :city, :zip_code, :state]
      expect(api_pie_doc.nested_attributes[1].values.flat_map(&:keys)).to eq [:cell_phone, :phone_number, :area_code]
    end

    specify "should give object docs" do
      expect(api_pie_doc.docs).to eq []
    end
  end

  describe "#build" do
    specify "should return a string of api_pie documentation params" do
      expect(api_pie_doc.build).to be_a String
    end
  end

  # describe "#attribute_as_api_doc" do
  #   specify "should add a line to the api documentation" do
  #     formatted_string = api_pie_doc.send(:attribute_as_api_doc, [:dob, {:type=>:string}])
  #     expect(formatted_string).to eq "param :dob, String, required: true"
  #   end
  # end

  # describe "#add_nested_attribute_to_doc" do
  #   specify "should add to docs array" do
  #     api_pie_doc.send(:add_nested_attribute_to_doc, { :i_like_pie => { pecan: { type: :string } } })
  #     expect(api_pie_doc.docs).to eq ["param :i_like_pie, Hash, required: true do", "param :pecan, String, required: true", "end"]
  #   end
  # end

  # describe "#attribute_type" do
  #   context "is passed a valid symbol type" do
  #     specify "should return a formatted string with constantized version of symbol" do
  #       expect(api_pie_doc.send(:attribute_type, :string)).to eq ", String"
  #     end
  #   end
  #   context "is passed a valid class as a string" do
  #     specify "should return a formatted string with constantized version of symbol" do
  #       expect(api_pie_doc.send(:attribute_type, 'String')).to eq ", String"
  #     end
  #   end
  #   context "is passes anything else" do
  #     specify "should raise an error" do
  #       expect{api_pie_doc.send(:attribute_type, 'Craziness')}.to raise_error(SimpleParams::ApiPieDoc::NotValidValueError)
  #     end
  #   end
  # end

  # describe "#attribute_required" do
  #   context "when passed true" do
  #     specify "should return a formatted string indicating the attribute is not required" do
  #       expect(api_pie_doc.send(:attribute_required, true)).to eq ""
  #     end
  #   end
  #   context "when passed false" do
  #     specify "should return a formatted string indicating the attribute is required" do
  #       expect(api_pie_doc.send(:attribute_required, false)).to eq ", required: true"
  #     end
  #   end
  #   context "when passed anything other than true or false" do
  #     specify "should return a formatted string indicating the attribute is required" do
  #       expect(api_pie_doc.send(:attribute_required, "blahblah")).to eq ", required: true"
  #     end
  #   end
  # end
end
