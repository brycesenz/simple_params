require 'active_support/core_ext/string'

module SimpleParams
  module RailsHelpers
    extend ActiveSupport::Concern
    included do
      def to_model
        self
      end
      def name_came_from_user?; end
      def _destroy_came_from_user?; end

      # Required for ActiveModel
      def persisted?
        false
      end

      # Needed for nested_model helpers that try to iterate over
      # all associations
      def each
        self
      end

      def marked_for_destruction?
        _destroy.eql?(true)
      end
    end

    module ClassMethods
      attr_accessor :rails_helpers

      def with_rails_helpers
        @rails_helpers = true
      end

      def using_rails_helpers?
        @rails_helpers||= false
        !!@rails_helpers
      end
      # http://apidock.com/rails/ActiveRecord/Reflection/AssociationReflection/klass
      # class Author < ActiveRecord::Base
      #   has_many :books
      # end

      # Author.reflect_on_association(:books).klass
      # # => Book
      def reflect_on_association(assoc_sym)
        nested_classes[assoc_sym]
      end

      # # Used with reflect_on_association
      def klass
        self
      end

      def define_rails_helpers(name, klass)
        # E.g. if we have a nested_class named :phones, then we need:
        #  - a method called :phones_attributes that also sets :phones
        #  - a method called :build_phone
        define_method("#{name}_attributes=") do |value|
          send("#{name}=", value)
        end

        # TODO: This needs more testing
        singular_key = singularized_key(name)
        define_method("build_#{singular_key}") do |value={}|
          klass.new(value, self, name)
        end
      end

      private
      def singularized_key(key)
        key.to_s.singularize
      end
    end
  end
end