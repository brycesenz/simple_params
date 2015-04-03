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
      value = options[:optional]
      case value
      when true
        "required: false"
      when false
        "required: true"
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
