class Reading < ApplicationMemory
  attribute :id, :string, default: -> { SecureRandom.uuid }
  attribute :device_id, :string
  attribute :timestamp, :datetime
  attribute :count # can't typecast to integer, otherwise it bypasses validation with value 0

  with_options presence: true do
    validates :device_id,
              :timestamp,
              :count
  end

  validates :count, numericality: { only_integer: true }
end
