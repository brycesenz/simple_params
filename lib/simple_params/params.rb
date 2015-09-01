require "active_model"
require "virtus"

module SimpleParams
  class Params
    include Virtus.model
    include ActiveModel::Validations
    extend ActiveModel::Naming
    include SimpleParams::RailsHelpers
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
            klass_instance = klass.new({}, self)
            init_value = if opts[:optional]
              NilParams.define_nil_class(klass).new
            else 
              klass_instance
            end
            init_value = klass.hash? ? init_value : [init_value]
            instance_variable_set("@#{name}", init_value)
          end
        end

        define_method("#{name}=") do |initializer|
          init_value = if initializer.is_a?(Array)
            if klass.with_ids?
              initializer.first.each_pair.inject([]) do |array, (key, val)|
                array << klass.new({key => val}, self)
              end
            else
              initializer.map { |val| klass.new(val, self) }
            end
          else
            klass.new(initializer, self)
          end
          instance_variable_set("@#{name}", init_value)
        end
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
