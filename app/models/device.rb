class Device < ApplicationMemory
  attribute :id, :string

  validates :id,
            presence: true,
            uniqueness: true

  has_many :readings

  def latest_timestamp(offset = "")
    latest = readings.max_by { |reading| reading.timestamp }

    return if latest.nil?

    offset = offset.presence || latest.offset

    latest.timestamp
          .to_datetime
          .new_offset(offset)
          .iso8601
  end

  def cumulative_count
    readings.sum { |reading| reading.count }
  end
end
