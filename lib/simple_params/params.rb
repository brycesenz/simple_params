require "active_model"
require "virtus"

module SimpleParams
  class Params
    include Virtus.model
    include ActiveModel::Validations
    extend ActiveModel::Naming
    include SimpleParams::Validations
    include SimpleParams::HasAttributes
    include SimpleParams::HasTypedParams
    include SimpleParams::HashHelpers
    include SimpleParams::DateTimeHelpers
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
        attr_accessor name
        klass = NestedParams.define_new_hash_class(self, name, opts, &block)
        add_nested_class(name, klass)
      end
      alias_method :nested_param, :nested_hash
      alias_method :nested, :nested_hash

      def nested_array(name, opts={}, &block)
        attr_accessor name
        klass = NestedParams.define_new_array_class(self, name, opts, &block)
        add_nested_class(name, klass)
      end

      private
      def add_nested_class(name, klass)
        @nested_classes ||= {}
        @nested_classes[name.to_sym] = klass
      end
    end

    attr_accessor :original_params
    alias_method :original_hash, :original_params
    alias_method :raw_params, :original_params

    def initialize(params={})
      set_strictness

      @original_params = hash_to_symbolized_hash(params)
      define_attributes(@original_params)

      # Nested Classes
      @nested_classes = nested_classes.keys

      set_accessors(params)
      initialize_nested_classes
    end

    def to_hash
      hash = {}
      attributes.each do |attribute|
        raw_attribute = send(attribute)
        if raw_attribute.is_a?(SimpleParams::Params)
          hash[attribute] = send(attribute).to_hash
        elsif raw_attribute.is_a?(Array)
          attribute_array = []
          raw_attribute.each do |r_attr|
            attribute_array << r_attr.to_hash
          end
          hash[attribute] = attribute_array
        else
          hash[attribute] = send(attribute)
        end
      end

      hash
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
        unless value.is_a?(Hash) 
          send("#{attribute_name}=", value)
        end
      end
    end

    def defined_attributes
      self.class.defined_attributes
    end

    def nested_classes
      self.class.nested_classes
    end

    def initialize_nested_classes
      nested_classes.each do |key, klass|
        if klass.array?
          initialization_params = @original_params[key.to_sym] || []
          initialization_array = []
          initialization_params.each do |initialization_param|
            initialization_array << klass.new(initialization_param, self)
          end
          send("#{key}=", initialization_array)
        elsif klass.hash?
          initialization_params = @original_params[key.to_sym] || {}
          send("#{key}=", klass.new(initialization_params, self))
        end
      end
    end
  end
end
