module SimpleParams
  module ValidationMatchers
    def have_required_parameter(attr)
      RequiredParameterMatcher.new(attr)
    end

    class RequiredParameterMatcher < ValidationMatcher
      attr_accessor :default_value, :attribute

      def initialize(attribute)
        super(attribute)
        @default_value = nil
        @attribute = attribute
      end

      def with_default(value)
        @default_value = value
        self
      end

      def with_allowed_values(*values)
        @allowed_values = values
        self
      end

      def matches?(subject)
        super(subject)
        @expected_message ||= :blank

        if @default_value
          matches_default_value?
        elsif @allowed_values
          disallows_value_of(nil) || matches_allowed_values?
        else
          disallows_value_of(nil, @expected_message)
        end
      end

      def description
        "require #{@attribute} to be set"
      end

      def failure_message_for_should
        "Expected #{@default_value} to be set and to be one of #{@allowed_values}"
      end

      def failure_message_for_should_not
        "Expected #{@default_value} not to be set and not to be one of #{@allowed_values}"
      end

      private

      def matches_default_value?
        @subject.send(@attribute) == @default_value
      end

      def matches_allowed_values?
        allowed_values.include?(@subject.send(@attribute))
      end
    end
  end
end
