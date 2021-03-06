require "active_model"
require "virtus"

module SimpleParams
  class Attribute
    attr_reader :parent, :name, :type, :default, 
      :validations, :formatter

    def initialize(parent, name, opts={})
      @parent = parent
      @name = name.to_sym
      @type = TYPE_MAPPINGS[opts[:type]]
      @value = nil
      @default = opts[:default]
      @formatter = opts[:formatter]
      @validations = opts[:validations] || {}
    end

    def raw_value
      empty = @value.nil? || (@value.is_a?(String) && @value.blank?)
      empty ? raw_default : @value
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
    def raw_default
      if @default.is_a?(Proc)
        @default.call(parent, self)
      else
        @default
      end
    end
  end
end
