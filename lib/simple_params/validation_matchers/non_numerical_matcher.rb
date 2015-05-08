module SimpleParams
  module ValidationMatchers
    def have_non_numerical_value(attr)
      NonNumericalMatcher.new(attr)
    end

    class NonNumericalMatcher < ValidationMatcher
      attr_accessor :attribute
      
      def initialize(attribute)
        super(attribute)
        @attribute = attribute
      end

      def matches?(subject)
        super(subject)
        
        if subject.send(@attribute).to_s =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/
          false
        else
          true
        end
      end

      def description
        "allow #{@attribute} to be non-numeric value"
      end

      def failure_message_for_should
        "Expected #{@attribute} to be non-numeric value #{@subject.send(@attribute).inspect}"
      end

      def failure_message_for_should_not
        "Expected #{@default_value} not to be nil or to be one of"
      end
    end
  end
end
