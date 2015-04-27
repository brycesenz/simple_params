module SimpleParams
  module CustomMatchers
    class HaveRequiredParam < Shoulda::Matchers::ActiveModel::ValidatePresenceOfMatcher; end;

    def validate_presence_of(attr)
      super
    end

    alias :have_required_parameter :validate_presence_of 
  end
end