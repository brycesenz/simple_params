require 'spec_helper'

describe SimpleParams::Formatters do
  class Racecar
    include SimpleParams::Formatters

    def initialize(params={})
      params.each { |k,v| send("#{k}=",v) }
      run_formatters
    end

    attr_accessor :make, :model

    format :make, :strip_make_whitespace
    format :model, lambda { |car, model| model.upcase }

    def strip_make_whitespace
      self.make.strip
    end
  end

  describe "formatting with Procs" do
    it "does not break if initial attribute is nil" do
      car = Racecar.new
      car.model.should be_nil
    end

    it "formats attribute on initialize" do
      car = Racecar.new(make: "porsche", model: "boxster")
      car.model.should eq("BOXSTER")
    end
  end

  describe "formatting with methods" do
    it "does not break if initial attribute is nil" do
      car = Racecar.new
      car.make.should be_nil
    end

    it "formats attribute on initialize" do
      car = Racecar.new(make: "  Porsche     ")
      car.make.should eq("Porsche")
    end
  end
end
