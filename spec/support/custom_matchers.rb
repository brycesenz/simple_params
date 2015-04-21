module CustomMatchers
  RSpec::Matchers.define :have_optional_parameter do |attribute|
    match do |subject|
      model = subject.class.new(attribute.to_sym  => "1")
      model.send(attribute) != nil
    end
  end

  RSpec::Matchers.define :have_default_parameter do |attribute|
    match do |subject|
      @default_value = subject.send(attribute)
      @default_value != nil
    end

    chain :of do |value|
      @default_value == value
    end
  end
end

RSpec.configure do |config|
  config.include CustomMatchers
end