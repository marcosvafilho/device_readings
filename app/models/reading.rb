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

  validates :timestamp, uniqueness: { scope: :device_id }
  validates :count, numericality: { only_integer: true }

  # we don't want to raise RecordInvalid for duplicate records
  def save!
    if invalid?
      raise ActiveMemory::Errors::RecordNotUnique if errors.added?(:timestamp, :taken)
      raise ActiveMemory::Errors::RecordInvalid, errors.full_messages.join(", ") unless errors.added?(:timestamp, :taken)
    end

    save
  end
end
