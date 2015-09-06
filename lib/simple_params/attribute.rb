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

    def assign_parameter_attributes(pairs)
      @p6i ||= pairs["6i"]
      @p5i ||= pairs["5i"]
      @p4i ||= pairs["4i"]
      @p3i ||= pairs["3i"]
      @p2i ||= pairs["2i"]
      @p1i ||= pairs["1i"]
      if all_multiparams_present?
        self.value = parse_multiparams
      end
    rescue ArgumentError
      self.value = nil
    end

  private
    def raw_default
      if @default.is_a?(Proc)
        @default.call(parent, self)
      else
        @default
      end
    end

    def all_multiparams_present?
      if @type == Date
        [@p1i, @p2i, @p3i].all? { |p| !p.nil? }
      elsif (@type == DateTime) || (@type == Time)
        [@p1i, @p2i, @p3i, @p4i, @p5i, @p6i].all? { |p| !p.nil? }
      else
        true
      end
    end

    def parse_multiparams
      if @type == Date
        Date.new(@p1i.to_i, @p2i.to_i, @p3i.to_i)
      elsif @type == DateTime
        DateTime.new(@p1i.to_i, @p2i.to_i, @p3i.to_i, @p4i.to_i, @p5i.to_i, @p6i.to_i)
      elsif @type == Time
        Time.new(@p1i.to_i, @p2i.to_i, @p3i.to_i, @p4i.to_i, @p5i.to_i, @p6i.to_i)
      end
    end
  end
end
