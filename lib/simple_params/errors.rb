require "active_model"

module SimpleParams
  class Errors < ActiveModel::Errors

    def initialize(base, nested_attributes = [])
      super(base)
      @nested_attributes = symbolize_nested(nested_attributes)
    end

    def [](attribute)
      get(attribute.to_sym) || reset_attribute(attribute.to_sym)
    end

    def []=(attribute, error)
      add_error_to_attribute(attribute, error)
    end

    def add(attribute, message = :invalid, options = {})
      message = normalize_message(attribute, message, options)
      if exception = options[:strict]
        exception = ActiveModel::StrictValidationFailed if exception == true
        raise exception, full_message(attribute, message)
      end

      add_error_to_attribute(attribute, message)
    end

    def clear
      super
      @nested_attributes.each do |attribute|
        fetch_nested_attribute(attribute).errors.clear
      end
    end

    def empty?
      super &&
      @nested_attributes.all? do |attribute|
        fetch_nested_attribute(attribute).errors.empty?
      end
    end
    alias_method :blank?, :empty? 

    def include?(attribute)
      if fetch_nested_attribute(attribute)
        !fetch_nested_attribute(attribute).errors.empty?
      else
        messages[attribute].present?
      end
    end
    alias_method :has_key?, :include? 
    alias_method :key?, :include?

    def values
      messages.values +
      @nested_attributes.map do |attribute|
        fetch_nested_attribute(attribute).errors.values
      end
    end

    private
    def add_error_to_attribute(attribute, error)
      if fetch_nested_attribute(attribute)
        fetch_nested_attribute(attribute).errors[:base] = error
      else
        self[attribute] << error
      end
    end

    def reset_attribute(attribute)
      if fetch_nested_attribute(attribute)
        set(attribute.to_sym, fetch_nested_attribute(attribute).errors) 
      else
        set(attribute.to_sym, [])
      end
    end

    def fetch_nested_attribute(attribute)
      if @nested_attributes.include?(attribute)
        @base.send(attribute)
      end
    end

    def symbolize_nested(nested_attributes)
      nested_attributes.map { |x| x.to_sym }
    end
  end
end
