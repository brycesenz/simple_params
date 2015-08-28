module SimpleParams
  module DateTimeHelpers
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def define_date_helper_methods(name)
        define_method("#{name}(3i)=") do |day|
          attribute = send("#{name}_attribute")
          value = attribute.send("value") || Date.today
          attribute.send("value=", Date.new(value.year, value.month, day.to_i))
        end

        define_method("#{name}(2i)=") do |month|
          attribute = send("#{name}_attribute")
          value = attribute.send("value") || Date.today
          attribute.send("value=", Date.new(value.year, month.to_i, value.day))
        end

        define_method("#{name}(1i)=") do |year|
          attribute = send("#{name}_attribute")
          value = attribute.send("value") || Date.today
          attribute.send("value=", Date.new(year.to_i, value.month, value.day))
        end
      end

      def define_datetime_helper_methods(name)
        define_method("#{name}(6i)=") do |sec|
          attribute = send("#{name}_attribute")
          value = attribute.send("value") || Time.now.utc
          attribute.send("value=", Time.new(value.year, value.month, value.day, value.hour, value.min, sec.to_i, value.utc_offset))
        end

        define_method("#{name}(5i)=") do |minute|
          attribute = send("#{name}_attribute")
          value = attribute.send("value") || Time.now.utc
          attribute.send("value=", Time.new(value.year, value.month, value.day, value.hour, minute.to_i, value.sec, value.utc_offset))
        end

        define_method("#{name}(4i)=") do |hour|
          attribute = send("#{name}_attribute")
          value = attribute.send("value") || Time.now.utc
          attribute.send("value=", Time.new(value.year, value.month, value.day, hour.to_i, value.min, value.sec, value.utc_offset))
        end

        define_method("#{name}(3i)=") do |day|
          attribute = send("#{name}_attribute")
          value = attribute.send("value") || Time.now.utc
          attribute.send("value=", Time.new(value.year, value.month, day.to_i, value.hour, value.min, value.sec, value.utc_offset))
        end

        define_method("#{name}(2i)=") do |month|
          attribute = send("#{name}_attribute")
          value = attribute.send("value") || Time.now.utc
          attribute.send("value=", Time.new(value.year, month.to_i, value.day, value.hour, value.min, value.sec, value.utc_offset))
        end

        define_method("#{name}(1i)=") do |year|
          attribute = send("#{name}_attribute")
          value = attribute.send("value") || Time.now.utc
          attribute.send("value=", Time.new(year.to_i, value.month, value.day, value.hour, value.min, value.sec, value.utc_offset))
        end
      end
    end
  end
end
