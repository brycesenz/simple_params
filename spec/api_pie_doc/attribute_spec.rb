require 'spec_helper'

describe SimpleParams::ApiPieDoc::Attribute do
  let(:simple_param_attribute) { [:name, {:type=>:string}] }
  let(:nested_simple_param_attribute) {
    {:address=>
      {:street=>{:type=>:string},
       :city=>{:validations=>{:length=>{:in=>4..40}, :presence=>true}, :type=>:string},
       :zip_code=>{:optional=>true, :type=>:string},
       :state=>{:default=>"North Carolina", :type=>:string}
      },
    :options=>{desc: 'i like pie'}
    }
  }
  let(:api_pie_doc_attribute) { described_class.new(simple_param_attribute) }
  let(:nested_api_pie_doc_attribute) { described_class.new(nested_simple_param_attribute) }

  describe '#initialize' do

    specify 'should give instance an attribute' do
      expect(api_pie_doc_attribute.attribute).to eq simple_param_attribute
    end

    specify 'should set nested' do
      expect(api_pie_doc_attribute.nested).to eq false
    end
  end

  describe '#name' do
    context 'when attribute is nested' do
      specify 'should set respond with the right name' do
        expect(nested_api_pie_doc_attribute.name).to eq 'address'
      end
    end

    context 'when attribute is not nested' do
      specify 'should set respond with the right name' do
        expect(api_pie_doc_attribute.name).to eq 'name'
      end
    end
  end

  describe '#options' do
    context 'when attribute is nested' do
      specify 'should return nested attribute options' do
        expect(nested_api_pie_doc_attribute.options).to eq({desc: 'i like pie'})
      end
    end

    context 'when attribute is not nested' do
      specify 'should return the attributes options' do
        expect(api_pie_doc_attribute.options).to eq({ type: :string })
      end
    end
  end

  describe '#nested?' do
    context 'when attribute is nested' do
      specify 'should return true' do
        expect(nested_api_pie_doc_attribute.nested?).to eq true
      end
    end

    context 'when attribute is not nested' do
      specify 'should return false' do
        expect(api_pie_doc_attribute.nested?).to eq false
      end
    end
  end

  describe '#to_s' do
    context 'when attribute is nested' do
      specify 'should return properly formatted string' do
        expect(nested_api_pie_doc_attribute.to_s).to eq("param :address, Hash, desc: 'i like pie', required: true do\nparam :street, String, desc: '', required: true\nparam :city, String, desc: '', required: true\nparam :zip_code, String, desc: ''\nparam :state, String, desc: '', required: true\nend")
      end
    end

    context 'when attribute is not nested' do
      specify 'should return properly formatted string' do
        expect(api_pie_doc_attribute.to_s).to eq("param :name, String, desc: '', required: true")
      end
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

  describe "#requirement_description" do
    context "when attribute options[:optional] is true" do
      specify "should return a formatted string indicating the attribute is not required" do
        attribute = SimpleParams::ApiPieDoc::Attribute.new([:name, {:optional=>true}])
        expect(attribute.send(:requirement_description)).to eq ""
      end
    end

    context "when attribute options[:optional] is false" do
      specify "should return a formatted string indicating the attribute is required" do
        attribute = SimpleParams::ApiPieDoc::Attribute.new([:name, {:optional=>false}])
        expect(attribute.send(:requirement_description)).to eq "required: true"
      end
    end

    context "when passed anything other than true or false" do
      specify "should return a formatted string indicating the attribute is required" do
        attribute = SimpleParams::ApiPieDoc::Attribute.new([:name, {:optional=>:blah}])
        expect(attribute.send(:requirement_description)).to eq "required: true"
      end
    end
  end

  describe "#description" do
    context "when attribute options[:desc] is not nil" do
      specify "should use options[:desc] to populate attribute description" do
        attribute = SimpleParams::ApiPieDoc::Attribute.new([:name, {:desc => 'I like pie'}])
        expect(attribute.send(:description)).to eq "desc: 'I like pie'"
      end
    end

    context "when attribute options[:desc] is nil" do
      specify "should return an empty string as the description" do
        attribute = SimpleParams::ApiPieDoc::Attribute.new([:name, {}])
        expect(attribute.send(:description)).to eq "desc: ''"
      end
    end
  end
end
