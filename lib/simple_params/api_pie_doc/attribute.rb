module SimpleParams
  class ApiPieDoc::Attribute
    attr_accessor :attribute

    def initialize(simple_params_attribute)
      self.attribute = simple_params_attribute
      @nested = simple_params_attribute.is_a?(Hash)
    end

    def name
      nested? ? attribute.keys.first.to_s : attribute[0].to_s
    end

    def options
      nested? ? {} : attribute[1]
    end

    def nested?
      @nested
    end

    def to_s
      unless do_not_document?
        if nested?
          nested_description
        else
          attribute_description
        end
      end
    end

    private

    def do_not_document?
      options[:document].eql?(false)
    end

    def nested_description
      start = "param :#{name}, Hash, #{requirement_description} do"
      attribute_descriptors = []
      attribute.values.flat_map(&:to_a).each do |nested_attribute|
        attribute_descriptors << self.class.new(nested_attribute).to_s
      end
      finish = "end"
      [start, attribute_descriptors, finish].flatten.join("\n")
    end

    def attribute_description
      base = "param :#{name}"
      [base, type_description, requirement_description].reject(&:blank?).join(", ")
    end

    NotValidValueError = Class.new(StandardError)

    def type_description
      value = options[:type]
      case value
      when :string, :integer, :array, :hash
        "#{value.to_s.capitalize.constantize}"
      when 'String', 'Integer', 'Array', 'Hash'
        "#{value}"
      when :decimal, :datetime, :date, :time, :float, :boolean
        ""
      else
        raise NotValidValueError.new("Must be one of #{SimpleParams::Params::TYPES}")
      end
    end

    def requirement_description
      value = options[:optional]
      case value
      when true
        ""
      when false
        "required: true"
      else
        "required: true"
      end
    end
  end
end
