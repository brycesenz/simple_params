module SimpleParams
  class ApiPieDoc::NestedAttribute < ApiPieDoc::AttributeBase

    attr_accessor :attributes

    def initialize(simple_params_attribute)
      super
      self.attributes = attribute.values[0].map { |attribute| ApiPieDoc::Attribute.new(attribute) }
      self.options ||= attribute.delete(:options) || attribute[1]
    end

    def name
      attribute.keys.first.to_s
    end

    def to_s
      return nil if do_not_document?
      nested_description
    end

    private

    def nested_description
      start = "param :#{name}, Hash, #{description}, #{requirement_description} do"
      attribute_descriptors = []
      attributes.each { |attribute| attribute_descriptors << attribute.to_s }
      finish = "end"
      [start, attribute_descriptors, finish].flatten.join("\n")
    end
  end
end
