module SimpleParams
  module ValidationMatchers
    def have_optional_parameter(attr)
      OptionalParameterMatcher.new(attr)
    end

    class OptionalParameterMatcher < ValidationMatcher
      def matches?(subject)
        super(subject)
        allows_value_of(nil)
      end

      def description
        "allow #{@attribute} to be nil"
      end

      def with_default
        
      end
    end
  end
end
