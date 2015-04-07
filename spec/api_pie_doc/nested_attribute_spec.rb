require 'spec_helper'
require 'support/base_attribute_spec'

describe SimpleParams::ApiPieDoc::NestedAttribute do

  let(:simple_param_attribute) {
    {:address=>
      {:street=>{:type=>:string},
       :city=>{:validations=>{:length=>{:in=>4..40}, :presence=>true}, :type=>:string},
       :zip_code=>{:optional=>true, :type=>:string},
       :state=>{:default=>"North Carolina", :type=>:string}
      },
    :options=>{desc: 'i like pie'}
    }
  }
  let(:nested_attribute) { described_class.new(simple_param_attribute) }

  it_behaves_like 'a base attribute'

  describe '#initialize' do
    specify 'should give instance an attribute' do
      expect(nested_attribute.attribute).to eq simple_param_attribute
    end

    specify 'should give instance options' do
      expect(nested_attribute.options).to eq({ desc: 'i like pie' })
    end
  end

  describe '#name' do
    specify 'should set respond with the right name' do
      expect(nested_attribute.name).to eq 'address'
    end
  end

  describe '#options' do
    specify 'should return nested attribute options' do
      expect(nested_attribute.options).to eq({desc: 'i like pie'})
    end
  end

  describe '#to_s' do
    specify 'should return properly formatted string' do
      expect(nested_attribute.to_s).to eq("param :address, Hash, desc: 'i like pie', required: true do\nparam :street, String, desc: '', required: true\nparam :city, String, desc: '', required: true\nparam :zip_code, String, desc: '', required: false\nparam :state, String, desc: '', required: true\nend")
    end
  end
end
