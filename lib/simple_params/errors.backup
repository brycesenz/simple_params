require "active_model"

module SimpleParams
  class Errors < ActiveModel::Errors
    attr_reader :base

    def initialize(base, nested_classes = {})
      super(base)
      @base = base
      @nested_classes = symbolize_nested(nested_classes)
    end

    def [](attribute)
      if nested_attribute?(attribute)
        set_nested(attribute)
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
      @nested_classes.map do |attribute, klass| 
        if klass.is_a?(Array)
          klass.map { |k| k.errors.clear }
        else
          klass.errors.clear
        end
      end
    end

    def empty?
      super &&
      @nested_classes.all? do |attribute, klass| 
        if klass.is_a?(Array)
          klass.all? { |k| k.errors.empty? }
        else
          klass.errors.empty?
        end
      end

    end
    alias_method :blank?, :empty? 

    def include?(attribute)
      if nested_attribute?(attribute)
        !nested_class(attribute).errors.empty?
      else
        messages[attribute].present?
      end
    end
    alias_method :has_key?, :include? 
    alias_method :key?, :include?

    def values
      messages.values +
      @nested_classes.map do |key, klass|
        if klass.is_a?(Array)
          klass.map { |k| k.errors.values }
        else
          klass.errors.values
        end
      end
    end

    def full_messages
      parent_messages = map { |attribute, message| full_message(attribute, message) }
      nested_messages = @nested_classes.map do |attribute, klass|
        if klass.is_a?(Array)
          klass.map do |k|
            unless k.errors.full_messages.nil?
              k.errors.full_messages.map { |message| "#{attribute} " + message }
            end
          end
        else
          unless klass.errors.full_messages.nil?
            klass.errors.full_messages.map { |message| "#{attribute} " + message }
          end
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

      @nested_classes.map do |attribute, klass|
        if klass.is_a?(Array)
          error_messages = if full_messages
            klass.map do |k|
              k.errors.messages.each_with_object({}) do |(attr, array), messages|
                messages[attr] = array.map { |message| klass.errors.full_message(attr, message) }
              end
            end
          else
            klass.map { |k| k.errors.messages.dup }
          end
        else
          error_messages = if full_messages          
            klass.errors.messages.each_with_object({}) do |(attr, array), messages|
              messages[attr] = array.map { |message| klass.errors.full_message(attr, message) }
            end
          else
            klass.errors.messages.dup
          end
        end

        if error_messages.is_a?(Array) && error_messages.all?(&:empty?)
          return messages
        end
        unless error_messages.nil? || error_messages.empty?
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
    def nested_class(key)
      @nested_classes[key.to_sym]
    end

    def nested_attribute?(attribute)
      @nested_classes.keys.include?(attribute.to_sym)
    end

    def set_nested(attribute)
      klass = nested_class(attribute)
      errors = if klass.is_a?(Array)
        klass.map(&:errors)
      else
        klass.errors
      end
      set(attribute.to_sym, errors)
    end

    def add_error_to_attribute(attribute, error)
      if nested_attribute?(attribute)
        @nested_classes[attribute].errors.add(:base, error)
      else
        self[attribute] << error
      end
    end

    def symbolize_nested(nested)
      nested.inject({}) { |memo,(k,v) | memo[k.to_sym] = v; memo }
    end
  end
end
