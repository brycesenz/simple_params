module SimpleParams
  module ValidationMatchers
    def format(attr)
      FormatMatcher.new(attr)
    end

    class FormatMatcher < ValidationMatcher
      attr_accessor :default_value, :attribute

      def initialize(attribute)
        super(attribute)
        @unformatted_value = nil
      end

      def with_value(value)
        @unformatted_value = value
        self
      end

      def into(value)
        @expected_value = value
        self
      end

      def matches?(subject)
        super(subject)
        @subject.send("#{@attribute}=", @unformatted_value)
        @subject.send(attribute) == @expected_value
      end

      def description
        "Expect #{@attribute} with_value #{@unformatted_value} to format into #{@expected_value}"
      end

      def failure_message_for_should
        "Shouldn't expect #{@attribute} with_value #{@unformatted_value} to format into #{@expected_value}"
      end

      def failure_message_for_should_not
        "Expected #{@attribute} with_value #{@unformatted_value} to not format into #{@expected_value}"
      end

      private
    end
  end
end
