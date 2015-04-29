require 'spec_helper'

describe SimpleParams::ValidationMatchers::FormatMatcher do
  class FormatMatcher < SimpleParams::Params
    param :amount, type: :float, formatter: lambda { |params, amt| sprintf('%.2f', amt) }
    param :expiration_date, type: :date, formatter: lambda { |params, date| date.strftime("%Y-%m")}
    param :cost, type: :float, formatter: lambda { |params, amt| sprintf('%.2f', amt) }
  end

  subject { FormatMatcher.new }

  it { should format(:amount).with_value(10).into("10.00") }
  it { should format(:expiration_date).with_value(Date.new(2014, 2, 4)).into("2014-02") }
  it { should_not format(:cost).with_value(12).into("14.00") }
  it { should_not format(:expiration_date).with_value(Date.new(2016, 2, 4)).into("2014-02") }
end
