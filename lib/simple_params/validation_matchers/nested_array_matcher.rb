module SimpleParams
  module ValidationMatchers
    def have_nested_array(attr)
      NestedArrayMatcher.new(attr)
    end

    class NestedArrayMatcher < ValidationMatcher
      attr_accessor :attribute
      
      def initialize(attribute)
        super(attribute)
        @attribute = attribute
      end

      def matches?(subject)
        super(subject)
        subject.send(:nested_arrays).has_key?(@attribute)
      end

      def description
        "Should have nested array #{@attribute}"
      end

      def failure_message_for_should
        "Should have nested array #{@attribute}"
      end

      def failure_message_for_should_not
        "Should not have nested array #{@attribute}"
      end

      private

    end
  end
end
