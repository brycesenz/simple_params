module SimpleParams
  module ValidationMatchers
    def format(attr)
      FormatMatcher.new(attr)
    end

    class FormatMatcher < ValidationMatcher
      attr_accessor :default_value, :attribute

      def initialize(attribute)
        super(attribute)
        @attribute = attribute
        @default_value = nil
      end

      def with_value(value)
        @default_value = value
        self
      end

      def into(value)
        @expected_value = value
        self
      end

      def matches?(subject)
        super(subject)

        @subject = subject

        format_into? == @expected_value
        
      end

      def description
        "Expect #{@attribute} with_value #{@default_value} to format into #{@expected_value}"
      end

      def failure_message_for_should
        "Shouldn't expect #{@attribute} with_value #{@default_value} to format into #{@expected_value}"
      end

      def failure_message_for_should_not
        "Expected #{@attribute} with_value #{@default_value} to not format into #{@expected_value}"
      end

      private

      def format_into?
        @subject.instance_variable_get("@#{attribute}_attribute").instance_variable_get(:@formatter).call('',default_value)
      end
    end
  end
end
