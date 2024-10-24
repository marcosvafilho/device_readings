require 'rails_helper'

RSpec.describe Device, type: :model do
  describe 'validations' do
    let(:device) { described_class.new }

    it 'validates presence of id' do
      device.id = nil

      expect(device).not_to be_valid
      expect(device.errors.details[:id]).to include(error: :blank)
    end

    it 'validates uniqueness of id' do
      described_class.create!(id: "unique_id")

      device.id = "unique_id"

      expect(device).not_to be_valid
      expect(device.errors.details[:id]).to include(error: :taken)
    end
  end

  describe 'associations' do
    let(:device) { described_class.create!(id: 'device-model-1') }

    let!(:reading_1) {
      Reading.create!(device_id: device.id,
                      timestamp: 1.hour.ago,
                      count: 1,
                      offset: "+01:00")
    }

    let!(:reading_2) {
      Reading.create!(device_id: device.id,
                      timestamp: 2.hours.ago,
                      count: 2,
                      offset: "+01:00")
    }

    it 'has many readings' do
      expect(device.readings).to include(reading_1)
      expect(device.readings).to include(reading_2)
    end
  end

  describe '#latest_timestamp' do
    context "when associated readings exist" do
      let(:device) { described_class.create!(id: 'device-model-2') }

      let!(:reading_1) {
        Reading.create!(device_id: device.id,
                        timestamp: 1.hour.ago,
                        count: 1,
                        offset: "+01:00")
      }

      let!(:reading_2) {
        Reading.create!(device_id: device.id,
                        timestamp: 2.hours.ago,
                        count: 2,
                        offset: "+01:00")
      }

      it 'returns the latest timestamp' do
        formated_timestamp = reading_1.timestamp
                             .to_datetime
                             .new_offset(reading_1.offset)
                             .iso8601

        expect(device.latest_timestamp).to eq(formated_timestamp)
      end
    end

    context 'when associated readings do not exist' do
      let(:device) { described_class.create!(id: 'device-model-3') }

      it 'returns nil' do
        expect(device.latest_timestamp).to be_nil
      end
    end
  end

  describe '#cumulative_count' do
    context "when associated readings exist" do
      let(:device) { described_class.create!(id: 'device-model-4') }

      let!(:reading_1) {
        Reading.create!(device_id: device.id,
                        timestamp: 1.hour.ago,
                        count: 10,
                        offset: "+01:00")
      }

      let!(:reading_2) {
        Reading.create!(device_id: device.id,
                        timestamp: 2.hours.ago,
                        count: 20,
                        offset: "+01:00")
      }

      it 'returns the sum of all reading counts' do
        expect(device.cumulative_count).to eq(30)
      end
    end

    context 'when associated readings do not exist' do
      let(:device) { described_class.create!(id: 'device-model-5') }

      it 'returns 0' do
        expect(device.cumulative_count).to eq(0)
      end
    end
  end
end
