require 'spec_helper'

describe SimpleParams::Attribute do
  class House
    def initialize(params={})
      params.each { |k,v| send("#{k}=",v) }
    end

    attr_accessor :rooms, :rent

    def name
      "My house"
    end

    def capitalize(val)
      val.upcase
    end
  end

  let(:house) { House.new }

  describe "attributes" do
    let(:model) { described_class.new(house, "color")}

    it "has correct parent attribute" do
      model.parent.should eq(house)
    end

    it "has correct name attribute" do
      model.name.should eq(:color)
    end

    describe "setting and getting value" do
      let(:model) { described_class.new(house, "color")}

      it "has nil value" do
        model.value.should be_nil
      end

      it "can set value" do
        model.value = "Dummy"
        model.value.should eq("Dummy")
      end
    end
  end

  describe "coercion" do
    context "without type" do
      let(:model) { described_class.new(house, "color")}

      it "does not coerce value" do
        model.value = 1
        model.value.should eq(1)
      end
    end

    context "with :integer type" do
      let(:model) { described_class.new(house, "color", { type: :integer })}

      it "coerces values into Integer" do
        model.value = "1"
        model.value.should eq(1)
      end
    end

    context "with :decimal type" do
      let(:model) { described_class.new(house, "color", { type: :decimal })}

      it "coerces values into BigDecimal" do
        model.value = "1"
        model.value.should eq(BigDecimal.new("1.0"))
      end
    end

    context "with :float type" do
      let(:model) { described_class.new(house, "color", { type: :float })}

      it "coerces values into Float" do
        model.value = "1"
        model.value.should eq(1.0)
      end
    end

    context "with :boolean type" do
      let(:model) { described_class.new(house, "color", { type: :boolean })}

      it "coerces values into Boolean" do
        model.value = "0"
        model.value.should be_falsey
      end
    end

    context "with :object type" do
      let(:model) { described_class.new(house, "color", { type: :object })}

      it "coerces values into Object" do
        other_house = House.new
        model.value = other_house
        model.value.should eq(other_house)
      end
    end
  end

  describe "defaults" do
    context "with static default" do
      let(:model) { described_class.new(house, "color", { default: "something" })}

      it "uses default when value not set" do
        model.value.should eq("something")
      end
    end

    context "with Proc default" do
      let(:default) do
        lambda { |parent, param| parent.name + " " + "rocks!" }
      end
      let(:model) { described_class.new(house, "color", { default: default })}

      it "uses default when value not set" do
        model.value.should eq("My house rocks!")
      end
    end
  end

  describe "formatter" do
    context "with function reference" do
      let(:model) { described_class.new(house, "color", { formatter: :capitalize })}

      it "uses method formatter from parent" do
        model.value = "lower"
        model.value.should eq("LOWER")
      end
    end

    context "with Proc formatter" do
      let(:formatter) do
        lambda { |parent, param| parent.name + " " + param.upcase }
      end

      let(:model) { described_class.new(house, "color", { formatter: formatter })}

      it "uses Proc formatter on value" do
        model.value = "rocks"
        model.value.should eq("My house ROCKS")
      end
    end
  end
end
