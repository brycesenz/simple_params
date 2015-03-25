module SimpleParams
  class ApiPieDoc

    class ApiPieDocAttribute
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
          attribute_descriptors << ApiPieDocAttribute.new(nested_attribute).to_s
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
        docs << ApiPieDocAttribute.new(attribute).to_s
      end

      nested_attributes.each do |nested_attribute|
        docs << ApiPieDocAttribute.new(nested_attribute).to_s
      end

      docs.join("\n")
    end

    private

    def build_nested_attributes
      nested_hashes.each do |name, parameter_set|
        nested_attributes << { name => parameter_set.defined_attributes }
      end
    end

    # def attribute_as_api_doc(attribute)
    #   return if attribute[1][:document].eql? false
    #   "param :#{attribute[0]}#{attribute_type(attribute[1][:type])}#{attribute_required(attribute[1][:optional])}"
    # end

    # def add_nested_attribute_to_doc(nested_attribute)
    #   docs << "param :#{nested_attribute.keys[0]}, Hash#{attribute_required(nested_attribute)} do"

    #   nested_attribute.values.flat_map(&:to_a).each do |attribute|
    #     docs << ApiPieDocAttribute.new(attribute).to_s
    #   end

    #   docs << "end"
    # end

    # NotValidValueError = Class.new(StandardError)

    # def attribute_type(value)
    #   # Only string, array and hash are supported by ApiPie (Integer works)
    #   # see https://github.com/Apipie/apipie-rails#typevalidator
    #   case value
    #   when :string, :integer, :array, :hash
    #     ", #{value.to_s.capitalize.constantize}"
    #   when 'String', 'Integer', 'Array', 'Hash'
    #     ", #{value}"
    #   when :decimal, :datetime, :date, :time, :float, :boolean
    #     ""
    #   else
    #     raise NotValidValueError.new("Must be one of #{SimpleParams::Params::TYPES}")
    #   end
    # end

    # def attribute_required(value)
    #   case value
    #   when true
    #     ""
    #   when false
    #     ", required: true"
    #   else
    #     ", required: true"
    #   end
    # end
  end
end
