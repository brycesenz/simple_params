module SimpleParams
  class ApiPieDoc::Attribute < ApiPieDoc::AttributeBase

    def initialize(simple_params_attribute)
      super
      self.options ||= attribute[1]
    end

    def name
      attribute[0].to_s
    end

    def to_s
      return nil if do_not_document?
      attribute_description
    end

    private

    def attribute_description
      base = "param :#{name}"
      [base, type_description, description, requirement_description].reject(&:blank?).join(", ")
    end

    def type_description
      value = options[:type]
      case value
      when :string, :integer, :array, :hash, :object
        "#{value.to_s.capitalize.constantize}"
      when 'String', 'Integer', 'Array', 'Hash'
        "#{value}"
      when :decimal, :datetime, :date, :time, :float, :boolean
        ""
      else
        raise NotValidValueError.new("Must be one of #{SimpleParams::Params::TYPES}")
      end
    end
  end
end
