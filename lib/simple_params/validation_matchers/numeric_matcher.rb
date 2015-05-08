module SimpleParams
  module ValidationMatchers
    def have_numeric_value(attr)
      NumericMatcher.new(attr)
    end

    class NumericMatcher < ValidationMatcher
      attr_accessor :attribute
      
      def initialize(attribute)
        super(attribute)
        @attribute = attribute
      end

      def matches?(subject)
        super(subject)
        
        if subject.send(@attribute).to_s =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/
          true
        else
          false
        end
      end

      def description
        "allow #{@attribute} to be non-numeric value"
      end

      def failure_message_for_should
        "Expected #{@attribute} to be numeric value"
      end

      def failure_message_for_should_not
        "Expected #{@attribute} to be non-numeric value"
      end
    end
  end
end
