module SimpleParams
  class ApiPieDoc

    attr_accessor :base_attributes,
                  :nested_classes,
                  :nested_attributes,
                  :docs

    def initialize(simple_params)
      self.base_attributes = simple_params.defined_attributes
      self.nested_classes = simple_params.nested_classes
      self.nested_attributes = []
      self.docs = []

      build_nested_classes
    end

    def build
      base_attributes.each do |attribute|
        docs << Attribute.new(attribute).to_s
      end

      nested_attributes.each do |nested_class|
        docs << NestedAttribute.new(nested_class).to_s
      end

      docs.join("\n")
    end

    private

    def build_nested_classes
      nested_classes.each do |name, parameter_set|
        nested_attributes << { name => parameter_set.defined_attributes, options: parameter_set.options }
      end
    end
  end
end
