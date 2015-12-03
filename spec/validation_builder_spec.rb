require 'spec_helper'

describe SimpleParams::ValidationBuilder do
  context "with blank opts" do
    let(:builder) { described_class.new }

    it "has correct validations" do
      builder.build.should eq(
        { presence: true }
      )
    end
  end

  context "with only optional" do
    let(:opts) do
      {
        optional: true,
        validations: nil
      }
    end

    let(:builder) { described_class.new(opts) }

    it "has correct validations" do
      builder.build.should eq({})
    end
  end

  context "with default" do
    let(:opts) do
      {
        default: Proc.new { Time.now }
      }
    end

    let(:builder) { described_class.new(opts) }

    it "has correct validations" do
      builder.build.should eq( {})
    end
  end

  context "with other validations (simple)" do
    let(:opts) do
      {
        validations: { presence: true, length: { in: [0..20]} }
      }
    end

    let(:builder) { described_class.new(opts) }

    it "has correct validations" do
      builder.build.should eq(
        { presence: true, length: { in: [0..20] } }
      )
    end
  end

  context "with other validations (complex)" do
    let(:stored_proc) do
      lambda { |str| str.split(/\s+/) }
    end

    let(:opts) do
      {
        validations: { presence: true, length: { 
            minimum: 2, tokenizer: stored_proc
          } 
        }
      }
    end

    let(:builder) { described_class.new(opts) }

    it "has correct validations" do
      builder.build.should eq(
        { presence: true, length: { minimum: 2, tokenizer: stored_proc } }
      )
    end
  end
end
