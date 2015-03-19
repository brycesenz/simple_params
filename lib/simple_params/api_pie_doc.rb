module SimpleParams
  class ApiPieDoc

    attr_accessor :base_attributes,
                  :nested_hashes,
                  :nested_attributes,
                  :docs

    def initialize(simple_params)
      self.base_attributes = simple_params.defined_attributes
      self.nested_hashes = simple_params.nested_hashes
      self.nested_attributes = []
      self.docs = []

      build_nested_attributes
    end

    def build
      base_attributes.each do |attribute|
        docs << attribute_as_api_doc(attribute)
      end

      nested_attributes.each do |nested_attribute|
        add_nested_attribute_to_doc(nested_attribute)
      end

      docs.join("\n")
    end

    private

    def build_nested_attributes
      nested_hashes.each do |name, parameter_set|
        nested_attributes << { name => parameter_set.defined_attributes }
      end
    end

    def attribute_as_api_doc(attribute)
      return if attribute[1][:document].eql? false
      "param :#{attribute[0]}#{attribute_type(attribute[1][:type])}#{attribute_required(attribute[1][:optional])}"
    end

    def add_nested_attribute_to_doc(nested_attribute)
      docs << "param :#{nested_attribute.keys[0]}, Hash#{attribute_required(nested_attribute)} do"

      nested_attribute.values.flat_map(&:to_a).each do |attribute|
        docs << attribute_as_api_doc(attribute)
      end

      docs << "end"
    end

    NotValidValueError = Class.new(StandardError)

    def attribute_type(value)
      # Only string, array and hash are supported by ApiPie (Integer works)
      # see https://github.com/Apipie/apipie-rails#typevalidator
      case value
      when :string, :integer, :array, :hash
        ", #{value.to_s.capitalize.constantize}"
      when 'String', 'Integer', 'Array', 'Hash'
        ", #{value}"
      when :decimal, :datetime, :date, :time, :float, :boolean
        ""
      else
        raise NotValidValueError.new("Must be one of #{SimpleParams::Params::TYPES}")
      end
    end

    def attribute_required(value)
      case value
      when true
        ""
      when false
        ", required: true"
      else
        ", required: true"
      end
    end
  end
end
