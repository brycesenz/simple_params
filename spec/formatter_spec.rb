require 'spec_helper'

describe SimpleParams::Formatter do
  class MyAttribute
    def some_function(value)
      "dummy value = " + value
    end
  end

  let(:attribute) { MyAttribute.new }

  describe "formatting" do
    context "with method name formatter" do
      let(:formatter) { described_class.new(attribute, :some_function) }

      it "calls the method on the attribute" do
        formatter.format("myval").should eq("dummy value = myval")
      end
    end

    context "with Proc default" do
      let(:default) do
        lambda { |attribute, value| attribute.some_function("other") + ", not #{value}" }
      end

      let(:formatter) { described_class.new(attribute, default) }

      it "calls the Proc with attribute and value" do
        formatter.format("myval").should eq("dummy value = other, not myval")
      end
    end
  end
end
