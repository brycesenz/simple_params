module SimpleParams
  module DateTimeHelpers
    extend ActiveSupport::Concern

    module ClassMethods
      def define_date_helper_methods(name)
        define_method("#{name}(3i)=") do |day|
          attribute = send("#{name}_attribute")
          attribute.assign_parameter_attributes("3i" => day)
        end

        define_method("#{name}(2i)=") do |month|
          attribute = send("#{name}_attribute")
          attribute.assign_parameter_attributes("2i" => month)
        end

        define_method("#{name}(1i)=") do |year|
          attribute = send("#{name}_attribute")
          attribute.assign_parameter_attributes("1i" => year)
        end
      end

      def define_datetime_helper_methods(name)
        define_method("#{name}(6i)=") do |sec|
          attribute = send("#{name}_attribute")
          attribute.assign_parameter_attributes("6i" => sec)
        end

        define_method("#{name}(5i)=") do |minute|
          attribute = send("#{name}_attribute")
          attribute.assign_parameter_attributes("5i" => minute)
        end

        define_method("#{name}(4i)=") do |hour|
          attribute = send("#{name}_attribute")
          attribute.assign_parameter_attributes("4i" => hour)
        end

        define_method("#{name}(3i)=") do |day|
          attribute = send("#{name}_attribute")
          attribute.assign_parameter_attributes("3i" => day)
        end

        define_method("#{name}(2i)=") do |month|
          attribute = send("#{name}_attribute")
          attribute.assign_parameter_attributes("2i" => month)
        end

        define_method("#{name}(1i)=") do |year|
          attribute = send("#{name}_attribute")
          attribute.assign_parameter_attributes("1i" => year)
        end
      end
    end
  end
end
