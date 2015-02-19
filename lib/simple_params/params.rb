require "active_model"
require "virtus"

module SimpleParams
  class Params
    include Virtus.model
    include ActiveModel::Validations

    class << self
      def optional_param(name, opts={}, &block)
        opts.merge!(optional: true)
        param(name, opts, &block)
      end

      def param(name, opts={}, &block)
        @defaults ||= {}

        attr_accessor name
        default = opts[:default]

        if default.present?
          @defaults[name.to_sym] = default
        end

        validations = opts[:validations] || {}
        unless opts[:optional]
          validations.merge!(presence: true)
        end
        unless validations.empty?
          validates name, validations
        end
      end
      alias_method :required_param, :param

      def nested_param(name, opts={}, &block)
        param(name, opts={}, &block)
        nested_class = Class.new(Params)
        name_function = Proc.new {
          def self.model_name
            ActiveModel::Name.new(self, nil, "temp")
          end
        }
        nested_class.class_eval(&name_function)
        nested_class.class_eval(&block)
        @nested_params ||= {}
        @nested_params[name.to_sym] = nested_class.new
      end

      def defaults
        @defaults || {}
      end

      def nested_params
        @nested_params || {}
      end
    end

    def initialize(params={}, parent_params = self)
      @errors = SimpleParams::Errors.new(self)
      @parent_params = parent_params
      set_nested_params
      set_accessors(params)
      set_defaults
    end

    def set_accessors(params={})
      params.each do |key, value| 
        self.class.send(:attr_accessor, key)
        if value.is_a?(Hash)
          attribute = send("#{key}")
          attribute.set_accessors(value)
        else
          send("#{key}=", value)
        end
      end
    end

    def run_validations! #:nodoc:
      run_callbacks :validate
      self.class.nested_params.each do |key, value|
        send("#{key}").run_validations!
      end
      errors.empty?
    end

    def validate!
      unless valid?
        raise StandardError, errors.to_s
      end
    end

    private
    def set_nested_params
      self.class.nested_params.each do |key, value|
        # This is true
        send("#{key}=", value)          

        # These are the WIP lines
        errors.set("#{key}".to_sym, ActiveModel::Errors.new(send("#{key}"))) 
      end
    end

    def set_defaults
      self.class.defaults.each do |key, default_value|
        value = if default_value.is_a?(Proc)
          if default_value.arity == 0
            default_value.call
          else
            default_value.call(self)
          end
        else
          default_value
        end
        if send("#{key}").nil?
          send("#{key}=", value)
        end
      end
    end
  end
end