module SimpleParams
  module ValidationMatchers
    def coerce_param(attr)
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
        
        case @expected_coerce
        when :integer
          @subject.send("#{@attribute}=", "100.02")
          (@subject.send(attribute) == 100) &&
          (@subject.send(attribute).is_a?(TYPE_MAPPINGS[:integer]))
        when :string
          @subject.send("#{@attribute}=", 200)
          (@subject.send(attribute) == "200") &&
          (@subject.send(attribute).is_a?(TYPE_MAPPINGS[:string]))
        when :decimal
          @subject.send("#{@attribute}=", "100")
          (@subject.send(attribute) == 100.0) &&
          (@subject.send(attribute).is_a?(TYPE_MAPPINGS[:decimal]))
        when :datetime 
          @subject.send("#{@attribute}=", DateTime.new(2014,2,3))
          @subject.send(attribute).is_a?(TYPE_MAPPINGS[:datetime])
        when :date
          @subject.send("#{@attribute}=", Date.new(2014,2,3))
          @subject.send(attribute).is_a?(TYPE_MAPPINGS[:date])
        when :time
          @subject.send("#{@attribute}=", Time.new(2007,11,5,11,21,0, "-05:00"))
          @subject.send(attribute).is_a?(TYPE_MAPPINGS[:time])
        when :float
          @subject.send("#{@attribute}=", "20")
          (@subject.send(attribute) == 20.0) &&
          (@subject.send(attribute).is_a?(TYPE_MAPPINGS[:float]))
        when :boolean
          @subject.send("#{@attribute}=", 0)
          (@subject.send(attribute) == false) &&
          (@subject.send(attribute).is_a?(TrueClass) || @subject.send(attribute).is_a?(FalseClass))
        when :array
          @subject.send("#{@attribute}=", ["red, green, blue"])
          @subject.send(attribute).is_a?(TYPE_MAPPINGS[:array])
        when :hash
          @subject.send("#{@attribute}=", { "dog"=>1, "cat"=>2, "fish"=>3 })
          @subject.send(attribute).is_a?(TYPE_MAPPINGS[:hash])
        when :object
          @subject.send("#{@attribute}=", "programmer")
          @subject.send(attribute).is_a?(TYPE_MAPPINGS[:object])
        else
          false
        end


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
