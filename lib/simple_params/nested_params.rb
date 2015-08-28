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

      def define_new_hash_class(parent, name, options, &block)
        options = options.merge(type: :hash)
        define_new_class(parent, name, options, &block)
      end

      def define_new_array_class(parent, name, options, &block)
        options = options.merge(type: :array)
        define_new_class(parent, name, options, &block)
      end

      private
      def define_new_class(parent, name, options, &block)
        klass_name = name.to_s.split('_').collect(&:capitalize).join
        Class.new(self).tap do |klass|
          parent.const_set(klass_name, klass)
          extend ActiveModel::Naming
          klass.class_eval(&block)
          klass.class_eval("self.options = #{options}")
        end
      end
    end

    def initialize(params={}, parent = nil)
      @parent = parent
      super(params)
    end

    # TODO: we need to test this!!

    def id
      @id
    end

    def set_accessors(params={})
      if class_has_ids?
        @id = params.keys.first
        params = params.values.first
      end

      super(params)
    end

    # def attributes
    #   super - [:type]
    # end

    private
    def class_has_ids?
      self.class.with_ids?
    end
  end
end
