require "active_model"
require "virtus"

module SimpleParams
  class Params
    include Virtus.model
    include ActiveModel::Validations
    extend ActiveModel::Naming
    include SimpleParams::Validations

    TYPES = [
      :integer,
      :string,
      :decimal,
      :datetime,
      :date,
      :time,
      :float,
      :boolean,
      :array,
      :hash,
      :object
    ]

    class << self

      TYPES.each do |sym|
        define_method("#{sym}_param") do |name, opts={}|
          param(name, opts.merge(type: sym))
        end
      end

      attr_accessor :strict_enforcement, :options

      def model_name
        ActiveModel::Name.new(self)
      end

      def api_pie_documentation
        SimpleParams::ApiPieDoc.new(self).build
      end

      def strict
        @strict_enforcement = true
      end

      def allow_undefined_params
        @strict_enforcement = false
      end

      def param(name, opts={})
        define_attribute(name, opts)
        add_validations(name, opts)
      end

      def nested_hash(name, opts={}, &block)
        attr_accessor name
        nested_class = define_nested_class(name, opts, &block)
        @nested_hashes ||= {}
        @nested_hashes[name.to_sym] = nested_class
      end
      alias_method :nested_param, :nested_hash
      alias_method :nested, :nested_hash

      def nested_hashes
        @nested_hashes ||= {}
      end

      def nested_array(name, opts={}, &block)
        attr_accessor name
        nested_array_class = define_nested_class(name, opts, &block)
        @nested_arrays ||= {}
        @nested_arrays[name.to_sym] = nested_array_class
      end

      def nested_arrays
        @nested_arrays ||= {}
      end

      def defined_attributes
        @define_attributes ||= {}
      end

      private
      def define_attribute(name, opts = {})
        opts[:type] ||= :string
        defined_attributes[name.to_sym] = opts
        attr_accessor "#{name}_attribute"

        define_method("#{name}") do
          attribute = send("#{name}_attribute")
          attribute.send("value")
        end

        define_method("#{name}=") do |val|
          attribute = send("#{name}_attribute")
          attribute.send("value=", val)
        end
      end

      def add_validations(name, opts = {})
        validations = opts[:validations] || {}
        has_default = opts.has_key?(:default) # checking has_key? because :default may be nil
        optional = opts[:optional]
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
        validates name, validations unless validations.empty?
      end

      def define_nested_class(name, options, &block)
        klass_name = name.to_s.split('_').collect(&:capitalize).join
        Class.new(Params).tap do |klass|
          self.const_set(klass_name, klass)
          extend ActiveModel::Naming
          klass.class_eval(&block)
          klass.class_eval("self.options = #{options}")
        end
      end
    end

    def initialize(params={}, parent = nil)
      # Set default strict params
      if self.class.strict_enforcement.nil?
        self.class.strict_enforcement = true
      end

      @parent = parent
      # Initializing Params
      @original_params = hash_to_symbolized_hash(params)
      define_attributes(@original_params)

      # Nested Hashes
      @nested_params = nested_hashes.keys

      # Nested Arrays
      @nested_arrays = nested_arrays.keys

      # Nested Classes
      set_accessors(params)
      initialize_nested_classes
      initialize_nested_array_classes
    end

    def define_attributes(params)
      self.class.defined_attributes.each_pair do |key, opts|
        send("#{key}_attribute=", Attribute.new(self, key, opts))
      end
    end

    def attributes
      (defined_attributes.keys + nested_hashes.keys + nested_arrays.keys).flatten
    end

    def original_params
      @original_params ||= {}
    end
    alias_method :original_hash, :original_params
    alias_method :raw_params, :original_params

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
      nested_errors_hash = {}
      @nested_params.each do |param|
        nested_errors_hash[param.to_sym] = send(param).errors
      end

      nested_arrays_hash = {}
      @nested_arrays.each do |array|
        nested_arrays_hash[array.to_sym] = send(array).map(&:errors)
      end

      @errors ||= SimpleParams::Errors.new(self, nested_errors_hash, nested_arrays_hash)
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

    private
    def strict_enforcement?
      self.class.strict_enforcement
    end

    def set_accessors(params={})
      params.each do |attribute_name, value|
        # Don't set accessors for nested classes
        unless value.is_a?(Hash) 
          send("#{attribute_name}=", value)
        end
      end
    end

    def hash_to_symbolized_hash(hash)
      hash.inject({}){|result, (key, value)|
        new_key = case key
                  when String then key.to_sym
                  else key
                  end
        new_value = case value
                    when Hash then hash_to_symbolized_hash(value)
                    else value
                    end
        result[new_key] = new_value
        result
      }
    end

    def defined_attributes
      self.class.defined_attributes
    end

    def nested_hashes
      self.class.nested_hashes
    end

    def nested_arrays
      self.class.nested_arrays
    end

    def initialize_nested_classes
      nested_hashes.each do |key, klass|
        initialization_params = @original_params[key.to_sym] || {}
        send("#{key}=", klass.new(initialization_params, self))
      end
    end

    def initialize_nested_array_classes
      nested_arrays.each do |key, klass|
        initialization_params = @original_params[key.to_sym] || []
        initialization_array = []
        initialization_params.each do |initialization_param|
          initialization_array << klass.new(initialization_param, self)
        end
        send("#{key}=", initialization_array)
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
  end
end
