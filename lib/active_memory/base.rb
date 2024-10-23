# frozen_string_literal: true

module ActiveMemory
  class Base
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations
    include ActiveMemory::Errors

    class << self
      def storage
        @storage ||= Concurrent::Hash.new
      end

      def find!(id)
        if (item = storage[id])
          item
        else
          raise ActiveMemory::Errors::RecordNotFound, "Couldn't find #{name} with id=#{id}"
        end
      end

      def find_by(attributes)
        item = storage.values.find do |item|
          attributes.all? { |attr_key, attr_value| item.send(attr_key) == attr_value }
        end
      end

      def find_or_create_by!(attributes)
        if (item = find_by(attributes))
          item
        else
          create!(attributes)
        end
      end

      def create!(attributes = {})
        item = new(attributes)

        item.save!
        item
      end

      def where(attributes)
        storage.values.select do |item|
          attributes.all? { |attr_key, attr_value| item.send(attr_key) == attr_value }
        end
      end
    end

    def initialize(attributes = {})
      super(attributes)
    end

    def save
      return false unless valid?

      self.class.storage[id] = self
      self
    end

    def save!
      raise ActiveMemory::Errors::RecordInvalid, errors.full_messages.join(", ") if invalid?

      save
    end
  end
end
