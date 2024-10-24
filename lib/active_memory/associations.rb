# frozen_string_literal: true

module ActiveMemory
  module Associations
    extend ActiveSupport::Concern

    module ClassMethods
      def has_many(association)
        define_method(association) do
          ivar = "@#{association}"
          association_class = association.to_s.classify.constantize
          query = association_class.where("#{self.class.name.underscore}_id" => self.id)

          instance_variable_set(ivar, query)
        end
      end
    end
  end
end
