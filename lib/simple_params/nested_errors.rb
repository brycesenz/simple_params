require "active_model"

module SimpleParams
  class NestedErrors < ActiveModel::Errors
    attr_reader :base

    def initialize(base)
      super(base)
      @base = base
    end

    def array?
      @base.array?
    end

    def hash?
      @base.hash?
    end

    def [](attribute)
      get(attribute.to_sym) || set(attribute.to_sym, [])
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
    end

    def empty?
      super
    end
    alias_method :blank?, :empty? 

    def include?(attribute)
      messages[attribute].present?
    end
    alias_method :has_key?, :include? 
    alias_method :key?, :include?

    def values
      messages.values
    end

    def full_messages
      map { |attribute, message| full_message(attribute, message) }
    end

    def to_hash(full_messages = false)
      get_messages(self, full_messages)
    end

    def to_s(full_messages = false)
      array = to_a.compact
      array.join(', ')
    end

    private
    def add_error_to_attribute(attribute, error)
      self[attribute] << error
    end

    def get_messages(object, full_messages = false)
      if full_messages
        object.messages.each_with_object({}) do |(attribute, array), messages|
          messages[attribute] = array.map { |message| object.full_message(attribute, message) }
        end
      else
        object.messages.dup
      end
    end

    def empty_messages?(msgs)
      msgs.nil? || msgs.empty?
    end
  end
end
