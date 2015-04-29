module SimpleParams
  module ValidationMatchers
    def have_optional_parameter(attr)
      OptionalParameterMatcher.new(attr)
    end

    class OptionalParameterMatcher < ValidationMatcher
      attr_accessor :default_value, :attribute
      
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
        if @default_value
          matches_default_value?
        else
          allows_value_of(nil)
        end
      end

      def description
        "allow #{@attribute} to be nil"
      end

      def failure_message_for_should
        "Expected with_default to yield #{@default_value}"
      end

      def failure_message_for_should_not
        "Not expected yield #{@default_value}"
      end

      private

      def matches_default_value?
        @subject.send(@attribute) == @default_value 
      end
    end
  end
end
