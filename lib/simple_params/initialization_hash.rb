module SimpleParams
  class InitializationHash < ::Hash
    include SimpleParams::HashHelpers

    DATETIME_INDICATORS = ['(6i)', '(5i)', '(4i)', '(3i)', '(2i)', '(1i)']

    attr_reader :original_params

    def initialize(inputs={})
      @original_params = hash_to_symbolized_hash(inputs)
      assign_parameters
    end

    private
    def assign_parameters
      original_params.each_pair do |key, value|
        date_time_found = false
        DATETIME_INDICATORS.each do |indicator|
          if key.to_s.include?(indicator)
            date_time_found = true
            key_name = key.to_s.partition(indicator).first
            assign_datetime_params(key_name)
          end
        end
        unless date_time_found
          assign_param(key, value)
        end
      end
    end

    def assign_datetime_params(key)
      p6i = original_params[:"#{key}(6i)"]
      p5i = original_params[:"#{key}(5i)"]
      p4i = original_params[:"#{key}(4i)"]
      p3i = original_params[:"#{key}(3i)"]
      p2i = original_params[:"#{key}(2i)"]
      p1i = original_params[:"#{key}(1i)"]
      value = if [p1i, p2i, p3i].all? && [p4i, p5i, p6i].none?
        Date.new(p1i.to_i, p2i.to_i, p3i.to_i)
      elsif [p6i, p5i, p4i, p3i, p1i, p1i].all?
        Time.new(p1i.to_i, p2i.to_i, p3i.to_i, p4i.to_i, p5i.to_i, p6i.to_i)
      end
      self[key.to_sym] = value
    rescue ArgumentError
      self[key.to_sym] = nil
    end

    def assign_param(key, value)
      self[key.to_sym] = value
    end
  end
end
