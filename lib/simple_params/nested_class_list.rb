module SimpleParams
  class NestedClassList
    attr_reader :parent

    def initialize(parent)
      @parent = parent
    end

    def to_hash
      nested_class_hash
    end

    def get_class_key(klass)
      nested_class_hash.each do |key, value|
        if value.is_a?(Array)
          return key if value.include?(klass)
        else
          return key if value == klass
        end
      end
    end

    def class_instances
      nested_class_hash.each_pair.inject([]) do |array, (_key, value)|
        array << value
        array.flatten.compact
      end
    end

    private
    def nested_class_hash
      @nested_class_hash ||= nested_class_attributes.inject({}) do |hash, param|
        hash[param.to_sym] = get_nested_class_from_parent(param)
        hash
      end
    end

    def nested_class_attributes
      @parent.nested_class_attributes
    end

    def get_nested_class_from_parent(klass)
      @parent.send(klass)
    end
  end
end
