module SimpleParams
  module ValidationMatchers
    def have_required_parameter(attr)
      RequiredParameterMatcher.new(attr)
    end

    class RequiredParameterMatcher < ValidationMatcher
      def matches?(subject)
        super(subject)
        @expected_message ||= :blank

        disallows_value_of(nil, @expected_message)
      end

      def description
        "require #{@attribute} to be set"
      end

      def with_default
        
      end
    end
  end
end
