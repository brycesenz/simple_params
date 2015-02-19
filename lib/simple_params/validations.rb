require "active_model"

module SimpleParams
  module Validations
    extend ActiveModel::Validations

    def run_validations! #:nodoc:
      run_callbacks :validate
      self.class.nested_params.each do |key, value|
        send("#{key}").run_validations!
      end
      errors.empty?
    end

    def validate!
      unless valid?
        raise StandardError, errors.to_s
      end
    end
  end
end
