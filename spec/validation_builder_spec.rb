require 'spec_helper'

describe SimpleParams::ValidationBuilder do
  let(:name) { "my_attribute" }

  context "with blank opts" do
    let(:builder) { described_class.new(name) }

    it "has correct validation string" do
      builder.validation_string.should eq(
        'validates :my_attribute, {:presence=>true}'
      )
    end
  end

  context "with optional" do
    let(:opts) do
      {
        optional: true
      }
    end

    let(:builder) { described_class.new(name, opts) }

    it "has correct validation string" do
      builder.validation_string.should eq('')
    end
  end

  context "with default" do
    let(:opts) do
      {
        default: Proc.new { Time.now }
      }
    end

    let(:builder) { described_class.new(name, opts) }

    it "has correct validation string" do
      builder.validation_string.should eq('')
    end
  end

  context "with other validations" do
    let(:opts) do
      {
        validations: { presence: true, length: { in: [0..20]} }
      }
    end

    let(:builder) { described_class.new(name, opts) }

    it "has correct validation string" do
      builder.validation_string.should eq(
        'validates :my_attribute, {:presence=>true, :length=>{:in=>[0..20]}}'
      )
    end
  end
end
