module SimpleParams
  module HasAttributes
    extend ActiveSupport::Concern
    included do
      def define_attributes(params)
        self.class.defined_attributes.each_pair do |key, opts|
          send("#{key}_attribute=", Attribute.new(self, key, opts))
        end
      end

      def attributes
        (defined_attributes.keys + nested_classes.keys).flatten
      end
    end

    module ClassMethods
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

        define_method("raw_#{name}") do
          attribute = send("#{name}_attribute")
          attribute.send("raw_value")
        end

        define_method("#{name}=") do |val|
          attribute = send("#{name}_attribute")
          attribute.send("value=", val)
        end

        if [Date, 'Date', :date].include?(opts[:type])
          define_date_helper_methods(name)
        elsif [DateTime, 'DateTime', :datetime, Time, 'Time', :time].include?(opts[:type])
          define_datetime_helper_methods(name)
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
    end
  end
end