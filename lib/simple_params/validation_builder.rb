module SimpleParams
  class ValidationBuilder
    def initialize(name, opts={})
      @name = name
      @opts = opts
    end

    def validation_string
      validations = @opts[:validations] || {}
      has_default = @opts.has_key?(:default) # checking has_key? because :default may be nil
      optional = @opts[:optional]
      if !validations.empty?
        if optional || has_default
          validations.merge!(allow_nil: true)
        else
          validations.merge!(presence: true)
        end
      else
        if !optional && !has_default
          validations.merge!(presence: true)
        end
      end

      if validations.empty?
        return  ''
      else
        return "validates :#{@name.to_sym}, #{validations}"
      end
    end
  end
end
