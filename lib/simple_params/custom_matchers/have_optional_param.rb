module SimpleParams
	module CustomMatchers
		class HaveOptionalParam < SimpleParams::Matchers
			attr_accessor :expected, :actual

			def initialize(expected)
	      @expected = expected
	    end

	    def matches?(actual)
	       @actual = actual
	       model = @actual.class.new(@expected => "1")
	       model.send(@expected) != nil
	    end

	    def failure_message_for_should
	      "expected '#{@expected}' to be optional parameter"
	    end

	    def failure_message_for_should_not
	      "expected '#{@expected}' not to be optional"
	    end
		end

		def have_optional_parameter(expected)
			HaveOptionalParam.new(expected)
		end
	end
end