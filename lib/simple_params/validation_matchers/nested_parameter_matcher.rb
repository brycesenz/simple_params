module SimpleParams
  module ValidationMatchers
    def have_nested_parameter(attr)
      NestedParameterMatcher.new(attr)
    end

    class NestedParameterMatcher < ValidationMatcher
      attr_accessor :attribute
      
      def initialize(attribute)
        super(attribute)
        @attribute = attribute
      end

      def matches?(subject)
        super(subject)
        subject.send(:nested_hashes).has_key?(@attribute)
      end

      def description
        "Should have nested param #{@attribute}"
      end

      def failure_message_for_should
        "Should have nested param #{@attribute}"
      end

      def failure_message_for_should_not
        "Should not have nested param #{@attribute}"
      end

      private

    end
  end
end
