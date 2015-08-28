module SimpleParams
  module StrictParams
    extend ActiveSupport::Concern

    included do
      def set_strictness
        if self.class.strict_enforcement.nil?
          self.class.strict_enforcement = true
        end
      end

      # Overriding this method to allow for non-strict enforcement!
      def method_missing(method_name, *arguments, &block)
        if strict_enforcement?
          raise SimpleParamsError, "parameter #{method_name} is not defined."
        else
          if @original_params.include?(method_name.to_sym)
            value = @original_params[method_name.to_sym]
            if value.is_a?(Hash)
              define_anonymous_class(method_name, value)
            else
              Attribute.new(self, method_name).value = value
            end
          end
        end
      end

      def respond_to?(method_name, include_private = false)
        if strict_enforcement?
          super
        else
          @original_params.include?(method_name.to_sym) || super
        end
      end

      def define_anonymous_class(name, hash)
        klass_name = name.to_s.split('_').collect(&:capitalize).join
        anonymous_klass = Class.new(Params).tap do |klass|
          if self.class.const_defined?(klass_name)
            begin
              self.class.send(:remove_const, klass_name)
            rescue NameError
            end
          end
          self.class.const_set(klass_name, klass)
        end
        anonymous_klass.allow_undefined_params
        anonymous_klass.new(hash)
      end

      def strict_enforcement?
        self.class.strict_enforcement
      end
    end

    module ClassMethods
      attr_accessor :strict_enforcement

      def strict
        @strict_enforcement = true
      end

      def allow_undefined_params
        @strict_enforcement = false
      end
    end
  end
end
