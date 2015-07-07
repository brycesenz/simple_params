require "active_model"

module SimpleParams
  module Validations
    extend ActiveModel::Validations

    # Overriding #valid? to provide recursive validating of 
    #  nested params
    def valid?(context = nil)
      current_context, self.validation_context = validation_context, context
      errors.clear
      run_validations!
      nested_hashes.each do |key, value|
        nested_class = send("#{key}") 
        nested_class.valid?
      end

      nested_arrays.each do |key, array|
        nested_array = send("#{key}") 
        nested_array.each { |a| a.valid? }
      end
      errors.empty?
    ensure
      self.validation_context = current_context
    end

    def validate!
      unless valid?
        raise SimpleParamsError, self.errors.to_hash.to_s
      end
    end
  end
end
