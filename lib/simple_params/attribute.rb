require "active_model"
require "virtus"

module SimpleParams
  class Attribute
    TYPE_MAPPINGS = {
      integer: Integer,
      string: String,
      decimal: BigDecimal,
      datetime: DateTime,
      date: Date,
      time: Time,
      float: Float,
      boolean: Axiom::Types::Boolean, # See note on Virtus
      array: Array,
      hash: Hash
    }

    attr_reader :parent
    attr_reader :name

    def initialize(parent, name, opts={})
      @parent = parent
      @name = name.to_sym
      @type = TYPE_MAPPINGS[opts[:type]] || String
      @value = nil
      @default = opts[:default]
      @formatter = opts[:formatter]
    end

    def raw_value
      @value || default
    end

    def value
      if @formatter.present?
        formatter = Formatter.new(@parent, @formatter)
        formatter.format(raw_value)
      else
        raw_value
      end
    end

    def value=(val)
      virtus_attr = Virtus::Attribute.build(@type)
      @value = virtus_attr.coerce(val)
    end

  private
    def default
      if @default.is_a?(Proc)
        @default.call(parent, self)
      else
        @default
      end
    end
  end
end
