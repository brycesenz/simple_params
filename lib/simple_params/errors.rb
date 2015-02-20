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
        if fetch_nested_attribute(attribute).present?
          fetch_nested_attribute(attribute).errors.clear
        end
      end
    end

    def empty?
      super &&
      @nested_attributes.all? do |attribute|
        if fetch_nested_attribute(attribute).present?
          fetch_nested_attribute(attribute).errors.empty?
        end
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
        if fetch_nested_attribute(attribute).present?
          fetch_nested_attribute(attribute).errors.values
        end
      end
    end

    def full_messages
      parent_messages = map { |attribute, message| full_message(attribute, message) }
      nested_messages = @nested_attributes.map do |attribute|
        if fetch_nested_attribute(attribute)
          messages = fetch_nested_attribute(attribute).errors.full_messages
          messages.map do |message|
            "#{attribute} " + message
          end
        end
      end
      (parent_messages + nested_messages).flatten
    end

    def to_hash(full_messages = false)
      messages = super(full_messages)
      nested_messages = @nested_attributes.map do |attribute|
        errors = nested_error_messages(attribute, full_messages)
        unless errors.empty?
          messages.merge!(attribute.to_sym => errors)
        end
      end
      messages
    end

    private
    def nested_error_messages(attribute, full_messages = false)
      if fetch_nested_attribute(attribute)
        if full_messages
          errors = fetch_nested_attribute(attribute).errors
          errors.messages.each_with_object({}) do |(attribute, array), messages|
            messages[attribute] = array.map { |message| errors.full_message(attribute, message) }
          end
        else
          fetch_nested_attribute(attribute).errors.messages.dup
        end
      else
        {}
      end
    end

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

    def symbolize_nested(nested)
      nested.map { |x| x.to_sym }
    end
  end
end
