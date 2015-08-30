module SimpleParams
  class NilParams < Params
    def initialize(params={})
      super(params)
    end

    def valid?
      true
    end

    def to_hash
      {}
    end

    def errors
      OpenStruct.new(
        empty?: true,
        clear: true,
        messages: {}
      )
    end
  end
end
