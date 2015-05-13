require 'spec_helper'

describe SimpleParams::ValidationMatchers::CoercionMatcher do
  class CoercionMatcherTestClass < SimpleParams::Params
    param :name, type: :string
    param :expiration_date, type: :date
    param :amount, type: :integer
    param :beginning_date, type: :datetime
    param :cost, type: :float
    param :weight, type: :decimal
    param :colors, type: :array
    param :animals, type: :hash
    param :title, type: :object
    param :office_hours, type: :time
    param :cellphone, type: :boolean


  end

  subject { CoercionMatcherTestClass.new }

  it { should coerce_param(:name).into(:string) }
  it { should coerce_param(:expiration_date).into(:date) }
  it { should_not coerce_param(:expiration_date).into(:datetime) }
  it { should coerce_param(:amount).into(:integer) }
  it { should coerce_param(:beginning_date).into(:datetime) }
  it { should coerce_param(:cost).into(:float) }
  it { should_not coerce_param(:cost).into(:integer) }
  it { should coerce_param(:weight).into(:decimal) }
  it { should_not coerce_param(:weight).into(:float) }
  it { should coerce_param(:colors).into(:array) }
  it { should coerce_param(:animals).into(:hash) }
  it { should coerce_param(:title).into(:object) }
  it { should coerce_param(:office_hours).into(:time) }
  it { should coerce_param(:cellphone).into(:boolean) }
end
