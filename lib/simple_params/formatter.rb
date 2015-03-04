require "active_model"

module SimpleParams
  class Formatter
    extend ActiveSupport::Concern

    def initialize(attribute, formatter)
      @attribute = attribute
      @formatter = formatter
    end

    def format(value)
      if @formatter.is_a?(Proc)
        @formatter.call(@attribute, value)
      else
        @attribute.send(@formatter, value)
      end
    end
  end
end
