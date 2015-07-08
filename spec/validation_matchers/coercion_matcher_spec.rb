require 'spec_helper'
require 'fixtures/validator_params'

describe SimpleParams::ValidationMatchers::CoercionMatcher do
  subject { ValidatorParams.new }

  it { should coerce_param(:name).into(:string) }
  it { should coerce_param(:birth_date).into(:date) }
  it { should_not coerce_param(:birth_date).into(:datetime) }
  it { should coerce_param(:age).into(:integer) }
  it { should coerce_param(:born_on).into(:datetime) }
  it { should_not coerce_param(:born_on).into(:date) }
  it { should coerce_param(:bank_balance).into(:float) }
  it { should_not coerce_param(:bank_balance).into(:integer) }
  it { should coerce_param(:weight).into(:decimal) }
  it { should_not coerce_param(:weight).into(:float) }
  it { should coerce_param(:favorite_colors).into(:array) }
  it { should coerce_param(:pets).into(:hash) }
  it { should coerce_param(:car).into(:object) }
  it { should coerce_param(:submitted_at).into(:time) }
  it { should_not coerce_param(:submitted_at).into(:date) }
  it { should_not coerce_param(:submitted_at).into(:datetime) }
  it { should coerce_param(:has_cellphone).into(:boolean) }
end
