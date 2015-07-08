require 'spec_helper'
require 'fixtures/validator_params'

describe SimpleParams::ValidationMatchers::FormatMatcher do
  subject { ValidatorParams.new }

  it { should format(:color).with_value("RED").into("red") }
  it { should format(:amount).with_value(1.2345).into(1.23) }
  it { should format(:bank_balance).with_value(1100.4).into("$1100.40") }
  it { should_not format(:birth_date).with_value(Date.new(2014, 1, 1)).into("1/1/2014") }
end
