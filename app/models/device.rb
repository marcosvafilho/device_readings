class Device < ApplicationMemory
  attribute :id, :string

  validates :id,
            presence: true,
            uniqueness: true

  has_many :readings

  def latest_timestamp
    latest = readings.max_by { |reading| reading.timestamp }

    return if latest.nil?

    latest.timestamp
          .to_datetime
          .iso8601
  end

  def cumulative_count
    readings.sum { |reading| reading.count }
  end
end
