require 'spec_helper'

describe SimpleParams::ValidationMatchers::CoercionMatcher do
  class CoercionMatcherTestClass < SimpleParams::Params
    param :amount, type: :float, formatter: lambda { |params, amt| sprintf('%.2f', amt) }
    param :expiration_date, type: :date, formatter: lambda { |params, date| date.strftime("%Y-%m")}
    param :cost, type: :float, formatter: lambda { |params, amt| sprintf('%.2f', amt) }
    param :weight, type: :decimal


  end

  subject { CoercionMatcherTestClass.new }

  it { should coerce_param(:amount).into(:float) }
  it { should coerce_param(:expiration_date).into(:date) }
  it { should coerce_param(:cost).into(:float) }
  it { should_not coerce_param(:cost).into(:integer) }
  it { should coerce_param(:weight).into(:decimal) }
end
