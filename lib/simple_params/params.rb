require "active_model"
require "virtus"

module SimpleParams
  class Params
    include Virtus.model
    include ActiveModel::Validations
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
        nested_class = define_nested_class(opts, &block)
        @nested_hashes ||= {}
        @nested_hashes[name.to_sym] = nested_class
      end
      alias_method :nested_param, :nested_hash
      alias_method :nested, :nested_hash

      def nested_hashes
        @nested_hashes || {}
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
        validations.merge!(presence: true) unless opts[:optional]
        validates name, validations unless validations.empty?
      end

      def define_nested_class(options, &block)
        Class.new(Params).tap do |klass|
          name_function = Proc.new {
            def self.model_name
              ActiveModel::Name.new(self, nil, "temp")
            end
          }
          klass.class_eval(&name_function)
          klass.class_eval(&block)
          klass.class_eval("self.options = options")
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

      # Errors
      @nested_params = nested_hashes.keys
      @errors = SimpleParams::Errors.new(self, @nested_params)

      # Nested Classes
      set_accessors(params)
      initialize_nested_classes
    end

    def define_attributes(params)
      self.class.defined_attributes.each_pair do |key, opts|
        send("#{key}_attribute=", Attribute.new(self, key, opts))
      end
    end

    def attributes
      (defined_attributes.keys + nested_hashes.keys).flatten
    end

    # Overriding this method to allow for non-strict enforcement!
    def method_missing(method_name, *arguments, &block)
      if strict_enforcement?
        raise SimpleParamsError, "parameter #{method_name} is not defined."
      else
        if @original_params.include?(method_name.to_sym)
          value = @original_params[method_name.to_sym]
          if value.is_a?(Hash)
            define_anonymous_class(value)
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
      hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    end

    def defined_attributes
      self.class.defined_attributes
    end

    def nested_hashes
      self.class.nested_hashes
    end

    def initialize_nested_classes
      nested_hashes.each do |key, klass|
        initialization_params = @original_params[key.to_sym] || {}
        send("#{key}=", klass.new(initialization_params, self))
      end
    end

    def define_anonymous_class(hash)
      klass = Class.new(Params).tap do |klass|
        name_function = Proc.new {
          def self.model_name
            ActiveModel::Name.new(self, nil, "temp")
          end
        }
        klass.class_eval(&name_function)
      end
      klass.allow_undefined_params
      klass.new(hash)
    end
  end
end
