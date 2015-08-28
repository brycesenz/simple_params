module SimpleParams
  module HasNestedClasses
    def nested_hash(name, opts={}, &block)
      attr_accessor name
      nested_class = NestedParams.define_new_hash_class(self, name, opts, &block)
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
      nested_class = NestedParams.define_new_array_class(self, name, opts, &block)
      @nested_arrays ||= {}
      @nested_arrays[name.to_sym] = nested_class
    end

    def nested_arrays
      @nested_arrays ||= {}
    end
  end
end
