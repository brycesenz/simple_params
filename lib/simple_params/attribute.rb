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
      hash: Hash,
      object: Object
    }

    attr_reader :parent
    attr_reader :name
    attr_reader :type

    def initialize(parent, name, opts={})
      @parent = parent
      @name = name.to_sym
      @type = TYPE_MAPPINGS[opts[:type]]
      @value = nil
      @default = opts[:default]
      @formatter = opts[:formatter]
    end

    def raw_value
      empty = @value.nil? || (@value.is_a?(String) && @value.blank?)
      empty ? default : @value
    end

    def value
      return raw_value if raw_value.blank?
      if @formatter.present?
        Formatter.new(@parent, @formatter).format(raw_value)
      else
        raw_value
      end
    end

    def value=(val)
      @value = if @type.present?
        virtus_attr = Virtus::Attribute.build(@type)
        virtus_attr.coerce(val)
      else
        val
      end
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
