require "active_model"

module SimpleParams
  class Errors < ActiveModel::Errors
    attr_reader :base

    def initialize(base, nested_hash_errors = {}, nested_array_errors = {})
      super(base)
      @base = base
      @nested_hash_errors = symbolize_nested(nested_hash_errors)
      @nested_array_errors = symbolize_nested(nested_array_errors)
    end

    def [](attribute)
      if is_a_nested_hash_error_attribute?(attribute)
        set(attribute.to_sym, @nested_hash_errors[attribute.to_sym])
      elsif is_a_nested_array_error_attribute?(attribute)
        set(attribute.to_sym, @nested_array_errors[attribute.to_sym])
      else
        get(attribute.to_sym) || set(attribute.to_sym, [])
      end
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
      @nested_hash_errors.map { |attribute, errors| errors.clear }
    end

    def empty?
      super &&
      @nested_hash_errors.all? { |attribute, errors| errors.empty? }
    end
    alias_method :blank?, :empty? 

    def include?(attribute)
      if is_a_nested_hash_error_attribute?(attribute)
        !@nested_hash_errors[attribute.to_sym].empty?
      else
        messages[attribute].present?
      end
    end
    alias_method :has_key?, :include? 
    alias_method :key?, :include?

    def values
      messages.values +
      @nested_hash_errors.map do |attribute, errors|
        errors.values
      end
    end

    def full_messages
      parent_messages = map { |attribute, message| full_message(attribute, message) }
      nested_messages = @nested_hash_errors.map do |attribute, errors|
        unless errors.full_messages.nil?
          errors.full_messages.map { |message| "#{attribute} " + message }
        end
      end
      (parent_messages + nested_messages).flatten
    end

    def to_hash(full_messages = false)
      messages = if full_messages
        msgs = {}
        self.messages.each do |attribute, array|
          msgs[attribute] = array.map { |message| full_message(attribute, message) }
        end
        msgs
      else
        self.messages.dup
      end

      @nested_hash_errors.map do |attribute, errors|
        error_messages = nested_error_messages(attribute, full_messages)
        unless errors.empty?
          messages.merge!(attribute.to_sym => error_messages)
        end
      end
      messages
    end

    def to_s(full_messages = false)
      array = to_a
      array.join(', ')
    end

    private
    def nested_error_messages(attribute, full_messages = false)
      if is_a_nested_hash_error_attribute?(attribute)
        errors = @nested_hash_errors[attribute.to_sym]
        if full_messages          
          errors.messages.each_with_object({}) do |(attr, array), messages|
            messages[attr] = array.map { |message| errors.full_message(attr, message) }
          end
        else
          errors.messages.dup
        end
      else
        {}
      end
    end

    def add_error_to_attribute(attribute, error)
      if is_a_nested_hash_error_attribute?(attribute)
        @nested_hash_errors[attribute.to_sym][:base] = error
      else
        self[attribute] << error
      end
    end

    def is_a_nested_hash_error_attribute?(attribute)
      @nested_hash_errors.keys.include?(attribute.to_sym)
    end

    def is_a_nested_array_error_attribute?(attribute)
      @nested_array_errors.keys.include?(attribute.to_sym)
    end

    def symbolize_nested(nested)
      nested.inject({}) { |memo,(k,v) | memo[k.to_sym] = v; memo }
    end
  end
end
