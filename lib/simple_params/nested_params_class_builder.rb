module SimpleParams
  class NestedParamsClassBuilder
    def initialize(parent)
      @parent = parent
    end

    #TODO: Need to test this!
    def build(nested_params, name, options, &block)
      klass_name = name.to_s.split('_').collect(&:capitalize).join
      Class.new(nested_params).tap do |klass|
        @parent.send(:remove_const, klass_name) if @parent.const_defined?(klass_name)
        @parent.const_set(klass_name, klass)
        klass.instance_eval <<-DEF
          def parent_class
            #{@parent}
          end
        DEF
        klass.class_eval('extend ActiveModel::Naming')
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
end
