module SimpleParams
  class NestedParams < Params
    class << self
      def type
        options[:type]
      end

      def array?
        type.to_sym == :array
      end

      def hash?
        type.to_sym == :hash
      end

      def with_ids?
        !!options[:with_ids]
      end

      def optional?
        !!options[:optional]
      end

      def define_new_hash_class(parent, name, options, &block)
        define_new_class(parent, name, options.merge(type: :hash), &block)
      end

      def define_new_array_class(parent, name, options, &block)
        define_new_class(parent, name, options.merge(type: :array), &block)
      end

      def build(params, parent, name)
        if params.is_a?(Array)
          params.map { |p| build_instance(p, parent, name) }.compact
        elsif with_ids?
          params.each_pair.map { |key, val| build_instance({key => val}, parent, name) }.compact
        else
          build_instance(params, parent, name)
        end
      end

      private
      def define_new_class(parent, name, options, &block)
        NestedParamsClassBuilder.new(parent).build(self, name, options, &block)
      end

      def build_instance(params, parent, name)
        instance = self.new(params, parent, name)
        instance.destroyed? ? nil : instance
      end
    end

    attr_reader :parent, :id, :params, :parent_attribute_name

    # Should allow NestedParams to be initialized with no arguments, in order
    #  to be compatible with some Rails form gems like 'nested_form'
    def initialize(params={}, parent = nil, parent_attribute_name = nil)
      @parent = parent
      @parent_attribute_name = parent_attribute_name
      if @parent_attribute_name.respond_to?(:to_sym)
        @parent_attribute_name = @parent_attribute_name.to_sym
      end
      @id = extract_id(params)
      @params = extract_initialization_params(params)
      super(@params)
    end

    def destroyed?
      sym_params = symbolize_params(params)
      [true, 1, "1", "true"].include?(sym_params[:_destroy])
    end

    private
    def with_ids?
      self.class.with_ids?
    end

    def symbolize_params(params)
      Hash[params.map{ |k, v| [k.to_sym, v] }]
    end

    def extract_id(params)
      if with_ids?
        id = params.keys[0]
        id ? id.to_sym : nil
      end
    end

    def extract_initialization_params(params)
      if with_ids?
        params.values[0] || {}
      else
        params || {}
      end
    end
  end
end
