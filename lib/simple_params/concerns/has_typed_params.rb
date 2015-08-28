module SimpleParams
  module HasTypedParams
    extend ActiveSupport::Concern

    TYPES = [
      :integer,
      :string,
      :decimal,
      :datetime,
      :date,
      :time,
      :float,
      :boolean,
      :array,
      :hash,
      :object
    ]

    included do
    end

    module ClassMethods
      TYPES.each do |sym|
        define_method("#{sym}_param") do |name, opts={}|
          param(name, opts.merge(type: sym))
        end
      end
    end
  end
end
