module SimpleParams
  module TestCustomMatchers
    class DummyClass < SimpleParams::Params
      param :name
      param :age, optional: true
    end
  end
end