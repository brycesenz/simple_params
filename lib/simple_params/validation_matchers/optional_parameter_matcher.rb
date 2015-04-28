module SimpleParams
  module ValidationMatchers
    def have_optional_parameter(attr)
      OptionalParameterMatcher.new(attr)
    end

    class OptionalParameterMatcher < ValidationMatcher
      attr_accessor :default_value, :attribute
      
      def initialize(attribute)
        super(attribute)
        @attribute = attribute
        @default_value = nil
      end

      def with_default(value)
        @default_value = value
        self
      end

      def matches?(subject)
        super(subject)
       
        @subject = subject 

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
        "Expected with_default to yield #{@default_value.inspect} &&&&&&&&&&&&&&&&&&&&&  #{@subject.inspect}********************** #{attribute} 000000000 #{self.default_value} +++++++ #{@subject.title}"
      end

      def failure_message_for_should_not
        "Not expected"
      end

      private

      def matches_default_value?
        @subject..to_s == self.default_value 
      end
    end
  end
end
