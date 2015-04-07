require 'spec_helper'
require 'support/base_attribute_spec'

describe SimpleParams::ApiPieDoc::Attribute do
  let(:simple_param_attribute) { [:name, {:type=>:string}] }
  let(:api_pie_doc_attribute) { described_class.new(simple_param_attribute) }

  it_behaves_like 'a base attribute'

  describe '#initialize' do
    specify 'should give instance an attribute' do
      expect(api_pie_doc_attribute.attribute).to eq simple_param_attribute
    end

    specify 'should give instance some options' do
      expect(api_pie_doc_attribute.options).to eq({ type: :string })
    end
  end

  describe '#name' do
    specify 'should set respond with the right name' do
      expect(api_pie_doc_attribute.name).to eq 'name'
    end
  end

  describe '#options' do
    specify 'should return the attributes options' do
      expect(api_pie_doc_attribute.options).to eq({ type: :string })
    end
  end

  describe '#to_s' do
    specify 'should return properly formatted string' do
      expect(api_pie_doc_attribute.to_s).to eq("param :name, String, desc: '', required: true")
    end
  end

  describe "#type_description" do
    context "where attribute.options[:type] is a accepted symbol" do
      specify "should return a formatted string with constantized version of symbol" do
        expect(api_pie_doc_attribute.send(:type_description)).to eq "String"
      end
    end

    context "where attribute.options[:type] is a accepted string" do
      specify "should return a formatted string with constantized version of symbol" do
        attribute = SimpleParams::ApiPieDoc::Attribute.new([:name, {:type=>'String'}])
        expect(attribute.send(:type_description)).to eq "String"
      end
    end

    context "where attribute.options[:type] is anything else" do
      specify "should raise an error" do
        attribute = SimpleParams::ApiPieDoc::Attribute.new([:name, {:type=>'Craziness'}])
        expect{attribute.send(:type_description)}.to raise_error(SimpleParams::ApiPieDoc::Attribute::NotValidValueError)
      end
    end
  end
end
