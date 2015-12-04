require "active_model"

module SimpleParams
  module Validations
    extend ActiveModel::Validations

    def valid?(context = nil)
      current_context, self.validation_context = validation_context, context
      errors.clear
      run_validations!

      # Make sure that nested classes are also valid
      nested_classes_valid? && errors.empty?
    ensure
      self.validation_context = current_context
    end

    def validate!
      unless valid?
        raise SimpleParamsError, self.errors.to_hash.to_s
      end
    end

    private
    def nested_classes_valid?
      # Need to map them, THEN call all?, otherwise validations won't get run
      # on every nested class
      validations = all_nested_classes.map { |klass| klass.valid? }
      validations.all?
    end
  end
end
