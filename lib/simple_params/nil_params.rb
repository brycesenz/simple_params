module SimpleParams
  class NilParams < NestedParams
    class << self
      def define_nil_class(parent)
        define_new_class(parent, :nil_params, {}) do
        end
      end

      def nested_classes
        if respond_to?(:parent_class) && parent_class.present?
          parent_class.nested_classes
        else
          {}
        end
      end
    end

    def initialize(params = {})      
      self.class.options ||= {}
      @mocked_object = if parent_class
        parent_class.new
      else
        nil
      end
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

    private
    def parent_class
      if self.class.respond_to?(:parent_class)
        self.class.parent_class
      else
        nil
      end
    end
  end
end
