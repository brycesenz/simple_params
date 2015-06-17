module SimpleParams
  module ValidationMatchers
    def have_optional_parameter(attr)
      OptionalParameterMatcher.new(attr)
    end

    class OptionalParameterMatcher < ValidationMatcher
      attr_accessor :default_value, :attribute, :allowed_values, :disallowed_values
      
      def initialize(attribute)
        super(attribute)
        @default_value = nil
        @attribute = attribute
        @allowed_values = nil
        @disallowed_values = nil
      end

      def with_default(value)
        @default_value = value
        self
      end

      def with_allowed_values(*values)
        @allowed_values = values
        self
      end

      def with_disallowed_values(*values)
        @disallowed_values = values
        self
      end

      def matches?(subject)
        super(subject)
        
        if @default_value
          matches_default_value?
        elsif @allowed_values
          allows_value_of(nil) && matches_allowed_values?
        elsif @disallowed_values
          allows_value_of(nil) && matches_disallowed_values?
        else
          allows_value_of(nil)
        end
        
      end

      def description
        "allow #{@attribute} to be nil"
      end

      def failure_message_for_should
        "Expected #{@default_value} either to be nil or one of #{@allowed_values}"
      end

      def failure_message_for_should_not
        "Expected #{@default_value} not to be nil or to be one of #{@allowed_values}"
      end

      private

      def matches_default_value?
        @subject.send(@attribute) == @default_value 
      end

      def matches_allowed_values?
        allowed_values.all? do |value|
          allows_value_of(value)
        end
      end

      def matches_disallowed_values?
        disallowed_values.all? do |value|
          disallows_value_of(value)
        end
      end
    end
  end
end
