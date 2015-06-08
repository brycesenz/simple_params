module SimpleParams
  class ApiPieDoc::AttributeBase
    attr_accessor :attribute, :options

    def initialize(simple_params_attribute)
      self.attribute = simple_params_attribute
    end

    private

    def do_not_document?
      options[:document].eql?(false)
    end

    NotValidValueError = Class.new(StandardError)

    def requirement_description
      optional = options[:optional]
      has_default = options.has_key?(:default)
      if optional || has_default
        "required: false"
      else
        "required: true"
      end
    end

    def description
      description = options[:desc] || ''
      "desc: '#{description}'"
    end
  end
end
