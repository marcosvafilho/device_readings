class Reading < ApplicationMemory
  attribute :id, :string, default: -> { SecureRandom.uuid }
  attribute :device_id, :string
  attribute :timestamp, :datetime
  attribute :count, :integer

  with_options presence: true do
    validates :device_id,
              :timestamp,
              :count
  end

  validates :count, numericality: { only_integer: true }
end
