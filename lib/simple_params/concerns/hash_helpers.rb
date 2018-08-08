module SimpleParams
  module HashHelpers
    extend ActiveSupport::Concern

    included do

      private
      def hash_to_symbolized_hash(hash)
        hash.to_h.inject({}){|result, (key, value)|
          new_key = case key
                    when String then key.to_sym
                    else key
                    end
          new_value = case value
                      when Hash then hash_to_symbolized_hash(value)
                      else value
                      end
          result[new_key] = new_value
          result
        }
      end
    end

    module ClassMethods
    end
  end
end
