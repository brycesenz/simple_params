require "active_model"

module SimpleParams
  class HashBuilder
    def initialize(params)
      @params = params
    end

    # TODO: This still needs specs around it, as well as a SIGNIFICANT refactor
    def build
      hash = {}
      attributes = @params.attributes
      attributes.each do |attribute|
        raw_attribute = @params.send(attribute)
        if raw_attribute.nil?
          hash[attribute] = nil
        elsif raw_attribute.is_a?(SimpleParams::Params)
          hash[attribute] = @params.send(attribute).to_hash
        elsif raw_attribute.is_a?(Array)
          attribute_array = []
          raw_attribute.each do |r_attr|
            unless r_attr.nil?
              attribute_array << r_attr.to_hash
            end
          end
          hash[attribute] = attribute_array
        else
          hash[attribute] = @params.send(attribute)
        end
      end
      hash
    end
  end
end
