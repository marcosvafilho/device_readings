# frozen_string_literal: true

module ActiveMemory
  class Base
    include ActiveModel::Model
    include ActiveModel::Attributes

    class << self
      def storage
        @storage ||= Concurrent::Hash.new
      end

      def find(id)
        storage[id]
      end
    end

    def initialize(attributes = {})
      super(attributes)
    end

    def save
      self.class.storage[id] = self
      self
    end
  end
end
