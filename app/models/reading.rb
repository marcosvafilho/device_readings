class Reading < ApplicationMemory
  attribute :id, :string, default: -> { SecureRandom.uuid }
  attribute :device_id, :string
  attribute :timestamp, :datetime
  attribute :count, :integer
end
