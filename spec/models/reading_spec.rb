require 'rails_helper'

RSpec.describe Reading, type: :model do
  let(:valid_attributes) do
    {
      device_id: 'reading-model-1',
      timestamp: Time.now,
      count: 10,
      offset: '+00:00'
    }
  end

  context 'validations' do
    it 'is valid with valid attributes' do
      reading = Reading.new(valid_attributes)
      expect(reading).to be_valid
    end

    it 'is invalid without a device_id' do
      reading = Reading.new(valid_attributes.except(:device_id))

      expect(reading).to be_invalid
      expect(reading.errors.details[:device_id]).to include(error: :blank)
    end

    it 'is invalid without a timestamp' do
      reading = Reading.new(valid_attributes.except(:timestamp))

      expect(reading).to be_invalid
      expect(reading.errors.details[:timestamp]).to include(error: :blank)
    end

    it 'is invalid without a count' do
      reading = Reading.new(valid_attributes.except(:count))

      expect(reading).to be_invalid
      expect(reading.errors.details[:count]).to include(error: :blank)
    end

    it 'is invalid without an offset' do
      reading = Reading.new(valid_attributes.except(:offset))

      expect(reading).to be_invalid
      expect(reading.errors.details[:offset]).to include(error: :blank)
    end

    it 'is invalid with a non-number count' do
      reading = Reading.new(valid_attributes)
      reading.count = "ten"

      expect(reading).to be_invalid
      expect(reading.errors.details[:count]).to include(error: :not_a_number, value: "ten")
    end

    it 'is invalid with a non-integer count' do
      reading = Reading.new(valid_attributes)
      reading.count = 9.99

      expect(reading).to be_invalid
      expect(reading.errors.details[:count]).to include(error: :not_an_integer, value: 9.99)
    end

    it 'is invalid if the timestamp is not unique for the same device_id' do
      Reading.create!(valid_attributes)
      reading = Reading.new(valid_attributes)

      expect(reading).to be_invalid
      expect(reading.errors.details[:timestamp]).to include(error: :taken)
    end
  end

  context 'custom save! method' do
    it 'raises RecordInvalid error for non-duplicate invalid records' do
      reading = Reading.new(valid_attributes.except(:device_id))
      expect { reading.save! }.to raise_error ActiveMemory::Errors::RecordInvalid
    end

    it 'does not raise RecordInvalid error for duplicate records' do
      Reading.create!(valid_attributes)
      duplicate_reading = Reading.new(valid_attributes)

      expect { duplicate_reading.save! }.not_to raise_error ActiveMemory::Errors::RecordInvalid
    end

    it 'raises RecordNotUnique error for duplicate records' do
      Reading.create!(valid_attributes)
      duplicate_reading = Reading.new(valid_attributes)

      expect { duplicate_reading.save! }.to raise_error ActiveMemory::Errors::RecordNotUnique
    end

    it 'saves the record when valid' do
      reading = Reading.new(valid_attributes)

      expect { reading.save! }.not_to raise_error
      expect(Reading.find!(reading.id)).to eq(reading)
    end
  end
end
