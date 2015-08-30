module SimpleParams
  class NilParams < Params
    def initialize(params = {}, mocked_object = nil)
      @mocked_object = mocked_object
      super(params)
    end

    def valid?
      true
    end

    def to_hash
      {}
    end

    def errors
      Errors.new(self)
    end

    def method_missing(method_name, *arguments, &block)
      if @mocked_object.present?
        @mocked_object.send(method_name, *arguments, &block)
      else
        super(method_name, *arguments, &block)
      end
    end

    def respond_to?(method_name, include_private = false)
      if @mocked_object.present?
        @mocked_object.respond_to?(:method) || super
      else
        super
      end
    end
  end
end
