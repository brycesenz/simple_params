require "active_model"
require "virtus"

module SimpleParams
  class Params
    include Virtus.model
    include ActiveModel::Validations
    include SimpleParams::Validations

    class << self
      TYPE_MAPPINGS = {
        integer: Integer,
        string: String,
        decimal: BigDecimal,
        datetime: DateTime,
        date: Time,
        time: DateTime,
        float: Float,
        # See note on Virtus
        boolean: Axiom::Types::Boolean,
        array: Array,
        hash: Hash
      }

      TYPE_MAPPINGS.each_pair do |sym, klass|
        define_method("#{sym}_param") do |name, opts={}|
          param(name, opts.merge(type: klass))
        end
      end

      def param(name, opts={})
        define_attribute(name, opts)
        add_validations(name, opts)
      end

      def nested_hash(name, opts={}, &block)
        attr_accessor name
        nested_class = define_nested_class(&block)
        @nested_hashes ||= {}
        @nested_hashes[name.to_sym] = nested_class
      end
      alias_method :nested_param, :nested_hash
      alias_method :nested, :nested_hash

      def nested_hashes
        @nested_hashes || {}
      end

      private
      def define_attribute(name, opts = {})
        type = opts[:type] || String
        default = opts[:default]
        if default.present?
          attribute name, type, default: default
        else
          attribute name, type
        end
      end

      def add_validations(name, opts = {})
        validations = opts[:validations] || {}
        validations.merge!(presence: true) unless opts[:optional]
        validates name, validations unless validations.empty?
      end

      def define_nested_class(&block)
        Class.new(Params).tap do |klass|
          name_function = Proc.new {
            def self.model_name
              ActiveModel::Name.new(self, nil, "temp")
            end
          }
          klass.class_eval(&name_function)
          klass.class_eval(&block)
        end
      end
    end

    def initialize(params={}, parent = nil)
      @parent = parent
      @original_params = hash_to_symbolized_hash(params)
      @nested_params = nested_hashes.keys
      @errors = SimpleParams::Errors.new(self, @nested_params)
      initialize_nested_classes
      set_accessors(params)
      # This method comes from Virtus
      # virtus/lib/virtus/instance_methods.rb
      set_default_attributes
    end

    protected
    def set_accessors(params={})
      params.each do |attribute_name, value| 
        # Don't set accessors for nested classes
        unless value.is_a?(Hash)
          send("#{attribute_name}=", value)
          reset_blank_attributes
        end
      end
    end

    def reset_blank_attributes
      # Reset to the default value for blank attributes
      attributes.each do |attribute_name, value|
        if send(attribute_name).blank?
          # This method comes from Virtus
          # virtus/lib/virtus/instance_methods.rb
          reset_attribute(attribute_name)
        end
      end
    end

    private
    def hash_to_symbolized_hash(hash)
      hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
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
  end
end