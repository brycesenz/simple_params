module SimpleParams
  module ValidationMatchers
    def have_required_parameter(attr)
      RequiredParameterMatcher.new(attr)
    end

    class RequiredParameterMatcher < ValidationMatcher

      def initialize(attribute)
        super(attribute)
        @default_value = nil
      end

      def with_default(value)
        @default_value = value
        self
      end

      def matches?(subject)
        super(subject)
        @expected_message ||= :blank

        if @default_value
          allows_value_of(nil, @expected_message) && allows_default_value
        else
          disallows_value_of(nil, @expected_message)
        end
      end

      def description
        "require #{@attribute} to be set"
      end

      private

      def allows_default_value
        @default_value
      end
    end
  end
end
