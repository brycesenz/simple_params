require "active_model"

module SimpleParams
  class Errors < ActiveModel::Errors

    def initialize(base, nested_attributes = [])
      super(base)
      @nested_attributes = []
    end

    def clear
      super
      @nested_attributes.each do |key, value|
        set("#{key}".to_sym, ActiveModel::Errors.new(@base.send("#{key}"))) 
      end
    end
  end
end
