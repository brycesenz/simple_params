module SimpleParams
  module CustomMatchers
    class HaveOptionalParam < Shoulda::Matchers::ActiveModel::AllowValueMatcher; end;
    
    def allow_value(*values)
      super
    end

    alias :have_optional_parameter :allow_value
  end
end