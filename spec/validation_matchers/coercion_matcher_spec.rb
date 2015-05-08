require 'spec_helper'

describe SimpleParams::ValidationMatchers::CoercionMatcher do
  class CoercionMatcherTestClass < SimpleParams::Params
    param :amount, type: :float, formatter: lambda { |params, amt| sprintf('%.2f', amt) }
    param :expiration_date, type: :date, formatter: lambda { |params, date| date.strftime("%Y-%m")}
    param :cost, type: :float, formatter: lambda { |params, amt| sprintf('%.2f', amt) }
  end

  subject { CoercionMatcherTestClass.new }

  it { should coerc_param(:amount).into(:float) }
  it { should coerc_param(:expiration_date).into(:date) }
  it { should_not coerc_param(:cost).into(:integer) }
end
