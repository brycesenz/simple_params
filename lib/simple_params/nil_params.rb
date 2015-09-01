module SimpleParams
  class NilParams < Params
    class << self
    end

    def initialize(params = {}, mocked_object = nil)
      @mocked_object = mocked_object
      define_class_nested_classes_method
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

    def class
      singleton_class
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

    private
    def define_class_nested_classes_method
      unless @mocked_object.nil?
        mocked_class = @mocked_object.class
        self.singleton_class.instance_eval <<-EOT
          def nested_classes
            #{mocked_class.nested_classes}
          end
        EOT
      end
    end
  end
end
