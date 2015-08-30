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
      nested_classes.map do |key, array|
        nested_class_valid?(send("#{key}") )
      end.all?
    end

    def nested_class_valid?(nested_class)
      if nested_class.is_a?(Array)
        # Have to map? & THEN all?, or else it won't
        #  necessarily call valid? on every object
        nested_class.map(&:valid?).all?
      else
        nested_class.present? ? nested_class.valid? : true
      end
    end
  end
end
