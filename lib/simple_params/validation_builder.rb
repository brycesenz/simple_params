module SimpleParams
  class ValidationBuilder
    def initialize(opts={})
      @opts = opts
      @validations = opts[:validations] || {}
    end

    def build
      if allow_nil?
        unless @validations.empty?
          @validations.merge!(allow_nil: true)
        end
      else
        @validations.merge!(presence: true)
      end

      @validations
    end

    private
    def has_default?
      @opts.has_key?(:default)
    end

    def optional?
      !!@opts[:optional]
    end

    def allow_nil?
      optional? || has_default?
    end
  end
end
