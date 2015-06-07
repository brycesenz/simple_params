require 'spec_helper'

class Example
  class ParamsOne < SimpleParams::Params
    param :name
    param :age, type: :integer, validations: { inclusion: { in: 18..100 } }

    nested_hash :address do
      param :street
      param :city, validations: { length: { in: 4..40 } }
      param :zip_code, optional: true
      param :state, optional: true, default: "North Carolina"
    end
  end

  class ParamsTwo < SimpleParams::Params
    param :name
    param :age, type: :integer, optional: true

    nested_hash :address do
      param :street
      param :city, validations: { length: { in: 4..40 } }
      param :zip_code
      param :state
      param :country
    end
  end
end

describe SimpleParams::Params do
  describe "api_pie_documentation", api_pie_documentation: true do
    it "generates valid api_pie documentation for Example::ParamsOne" do
      documentation = Example::ParamsOne.api_pie_documentation
      api_docs = <<-API_PIE_DOCS
        param :name, String, desc: '', required: true
        param :age, Integer, desc: '', required: true
        param :address, Hash, desc: '', required: true do
          param :street, String, desc: '', required: true
          param :city, String, desc: '', required: true
          param :zip_code, String, desc: '', required: false
          param :state, String, desc: '', required: false
        end
      API_PIE_DOCS

      expect(documentation).to be_a String
      expect(documentation.gsub(/\s+/, "")).to eq api_docs.gsub(/\s+/, "")
    end

    it "generates valid api_pie documentation for Example::ParamsTwo" do
      documentation = Example::ParamsTwo.api_pie_documentation
      api_docs = <<-API_PIE_DOCS
        param :name, String, desc: '', required: true
        param :age, Integer, desc: '', required: false
        param :address, Hash, desc: '', required: true do
          param :street, String, desc: '', required: true
          param :city, String, desc: '', required: true
          param :zip_code, String, desc: '', required: true
          param :state, String, desc: '', required: true
          param :country, String, desc: '', required: true
        end
      API_PIE_DOCS

      expect(documentation).to be_a String
      expect(documentation.gsub(/\s+/, "")).to eq api_docs.gsub(/\s+/, "")
    end
  end

  describe "acceptance", acceptance: true do
    it "is valid with only required params for Example::ParamsOne" do
      params = {
        name: "Tom",
        age: 21,
        address: {
          street: "1 Main St.",
          city: "Chicago"
        }
      }
      Example::ParamsOne.new(params).should be_valid
    end

    it "is valid with only required params for Example::ParamsTwo" do
      params = {
        name: "Tom",
        address: {
          street: "1 Main St.",
          city: "Chicago",
          zip_code: "20122",
          state: "IL",
          country: "USA"
        }
      }
      Example::ParamsTwo.new(params).should be_valid
    end
  end
end
