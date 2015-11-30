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
          parent.send(:remove_const, klass_name) if parent.const_defined?(klass_name)
          parent.const_set(klass_name, klass)
          klass.instance_eval <<-DEF
            def parent_class
              #{parent}
            end
          DEF
          extend ActiveModel::Naming
          klass.class_eval(&block)
          klass.class_eval("self.options = #{options}")
          if klass.parent_class.using_rails_helpers?
            klass.instance_eval("with_rails_helpers")
          end

          # define a _destroy param (Boolean, default: false)
          if klass.using_rails_helpers?
            klass.send(:define_attribute, :_destroy, {type: :boolean, default: false})
          end
        end
      end
    end

    def initialize(params={}, parent = nil)
      @parent = parent
      super(params)
    end

    def id
      @id ||= nil
    end

    def set_accessors(params={})
      if class_has_ids?
        @id = params.keys.first
        params = params.values.first || {}
      end

      super(params)
    end

    private
    def class_has_ids?
      self.class.with_ids?
    end

    def hash_class?
      self.class.hash?
    end

    def array_class?
      self.class.array?
    end
  end
end
