require "active_model"
require "virtus"

module SimpleParams
  class Params
    include Virtus.model
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    extend ActiveModel::Naming
    include SimpleParams::RailsHelpers
    include SimpleParams::Validations
    include SimpleParams::HasAttributes
    include SimpleParams::HasTypedParams
    include SimpleParams::StrictParams

    class << self
      attr_accessor :options

      def model_name
        ActiveModel::Name.new(self)
      end

      def api_pie_documentation
        SimpleParams::ApiPieDoc.new(self).build
      end

      def param(name, opts={})
        define_attribute(name, opts)
        add_validations(name, opts)
      end

      def add_validations(name, opts = {})
        validations = ValidationBuilder.new(opts).build
        validates name, validations unless validations.empty?
      end

      def nested_classes
        @nested_classes ||= {}
      end

      def nested_hashes
        nested_classes.select { |key, klass| klass.hash? }
      end

      def nested_arrays
        nested_classes.select { |key, klass| klass.array? }
      end

      def nested_hash(name, opts={}, &block)
        klass = NestedParams.define_new_hash_class(self, name, opts, &block)
        add_nested_class(name, klass, opts)
      end
      alias_method :nested_param, :nested_hash
      alias_method :nested, :nested_hash

      def nested_array(name, opts={}, &block)
        klass = NestedParams.define_new_array_class(self, name, opts, &block)
        add_nested_class(name, klass, opts)
      end

      private
      def add_nested_class(name, klass, opts)
        @nested_classes ||= {}
        @nested_classes[name.to_sym] = klass
        define_nested_accessor(name, klass, opts)
        if using_rails_helpers?
          define_rails_helpers(name, klass)
        end
      end

      def define_nested_accessor(name, klass, opts)
        define_method("#{name}") do
          if instance_variable_defined?("@#{name}")
            instance_variable_get("@#{name}")
          else
            # This logic basically sets the nested class to an instance of itself, unless
            #  it is optional.
            init_value = if opts[:optional]
              klass.hash? ? nil : []
            else 
              klass_instance = klass.new({}, self, name)
              klass.hash? ? klass_instance : [klass_instance]
            end
            instance_variable_set("@#{name}", init_value)
          end
        end

        define_method("#{name}=") do |initializer|
          init_value = klass.build(initializer, self, name)
          instance_variable_set("@#{name}", init_value)
        end
      end
    end

    attr_accessor :original_params
    alias_method :original_hash, :original_params
    alias_method :raw_params, :original_params

    def initialize(params={})
      set_strictness
      params = InitializationHash.new(params)
      @original_params = params.original_params
      define_attributes(@original_params)

      # Nested Classes
      @nested_classes = nested_classes.keys
      set_accessors(params)
    end

    def define_attributes(params)
      self.class.defined_attributes.each_pair do |key, opts|
        send("#{key}_attribute=", Attribute.new(self, key, opts))
      end
    end

    def to_hash
      HashBuilder.new(self).build
    end

    def errors
      nested_class_hash = {}
      @nested_classes.each do |param|
        nested_class_hash[param.to_sym] = send(param)
      end
      @errors ||= SimpleParams::Errors.new(self, nested_class_hash)
    end

    private
    def set_accessors(params={})
      params.each do |attribute_name, value|
        send("#{attribute_name}=", value)
      end
    end

    def defined_attributes
      self.class.defined_attributes
    end

    def nested_classes
      self.class.nested_classes
    end
  end
end
