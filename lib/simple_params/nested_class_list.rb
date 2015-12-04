module SimpleParams
  class NestedClassList
    attr_reader :parent

    def initialize(parent)
      @parent = parent
      @list = {}
      @hashes = []
      @arrays = []
      @all = []
    end

    def to_hash
      nested_class_hash = {}
      @parent.nested_class_attributes.each do |param|
        nested_class_hash[param.to_sym] = @parent.send(param)
      end
      nested_class_hash
    end

    # def add_class(instance, symbol, opts = {})
    #   if [:array, 'array'].include?(opts[:type])
    #     @list[symbol.to_sym] ||= []
    #     @list[symbol.to_sym] << instance
    #     @arrays << instance
    #   else
    #     @list[symbol.to_sym] = instance
    #     @hashes << instance
    #   end
    #   @all << instance
    #   instance
    # end

    # def [](symbol)
    #   @list[symbol.to_sym]
    # end
  end
end
