require "active_model"

module SimpleParams
  module Formatters
    extend ActiveSupport::Concern

    module ClassMethods
      def _formatters
        @_formatters || {}
      end

      def format(attribute, formatter)
        @_formatters ||= {}
        @_formatters[attribute.to_sym] = formatter
      end
    end

    def run_formatters
      _formatters.each do |attribute, method|
        value = send(attribute.to_sym)
        unless value.blank?
          out = evaluate_proc_or_method(attribute, method, value)
          send("#{attribute.to_sym}=", out)
        end
      end
    end

    private
    def evaluate_proc_or_method(attribute, method, value)
      if method.is_a?(Proc)
        method.call(self, value)
      else
        self.send(method)
      end
    end

    def _formatters
      self.class._formatters || {}
    end
  end
end
