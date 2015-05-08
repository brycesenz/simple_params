module SimpleParams
  module ValidationMatchers
    def coerc_param(attr)
      CoercionMatcher.new(attr)
    end

    class CoercionMatcher < ValidationMatcher
      attr_accessor :attribute

      def initialize(attribute)
        super(attribute)
        @attribute = attribute
      end

      def into(value)
        @expected_coerce = value
        self
      end

      def matches?(subject)
        super(subject)
        
        @expected_coerce.capitalize.to_s == @subject.send("#{@attribute}_attribute").instance_eval{@type}.to_s
  
      end

      def description
        "Expect #{@attribute} to coerce into #{@expected_coerce}"
      end

      def failure_message_for_should
        "Expect #{@attribute} to coerce into #{@expected_coerce}"
      end

      def failure_message_for_should_not
        "Expect #{@attribute} to not coerce into #{@expected_coerce}"
      end

      private
    end
  end
end
