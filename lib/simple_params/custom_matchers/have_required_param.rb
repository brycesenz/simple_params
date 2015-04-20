module SimpleParams	
	module CustomMatchers
	  class HaveRequiredParam
	    def initialize(expected)
	    	@expected = expected
	    end

	    def matches?(actual)
	    	@actual = actual
	    	@actual.respond_to?(@expected)
	    end

	    def failure_message
	    	"'#{@expected}' is required, but got '#{@actual}'"
	    end

	    def negative_failure_message
	    	"expected something else than '#{@expected}' and got '#{@actual}' which is a non-required param"
	    end
	  end

	  def have_required_param(expected)
	  	HaveRequiredParam.new(expected)
	  end
	end
end