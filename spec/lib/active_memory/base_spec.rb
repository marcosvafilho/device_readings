require 'rails_helper'

class DummyActiveMemory < ActiveMemory::Base
  attribute :id, :integer
  attribute :name, :string

  validates :name, presence: true
end

RSpec.describe ActiveMemory::Base, type: :model do
  let(:dummy_class) { DummyActiveMemory }

  describe '.storage' do
    it 'returns a Concurrent::Hash' do
      expect(dummy_class.storage).to be_a(Concurrent::Hash)
    end
  end

  describe '.find!' do
    it 'returns an item when it is found' do
      item = dummy_class.create!(id: 1, name: 'Test')
      expect(dummy_class.find!(1)).to eq(item)
    end

    it 'raises an error when item is not found' do
      expect { dummy_class.find!(999) }.to raise_error(ActiveMemory::Errors::RecordNotFound)
    end
  end

  describe '.find_by' do
    it 'returns an item that matches the given attributes' do
      item = dummy_class.create!(id: 2, name: 'Test2')
      expect(dummy_class.find_by(name: 'Test2')).to eq(item)
    end

    it 'returns nil when no item matches the given attributes' do
      expect(dummy_class.find_by(name: 'Nonexistent')).to be_nil
    end
  end

  describe '.find_or_create_by!' do
    it 'returns an existing item if one is found' do
      item = dummy_class.create!(id: 3, name: 'Test3')
      expect(dummy_class.find_or_create_by!(name: 'Test3')).to eq(item)
    end

    it 'creates a new item if none is found' do
      expect { dummy_class.find_or_create_by!(id: 4, name: 'Test4') }.to change { dummy_class.storage.count }.by(1)
    end
  end

  describe '.create!' do
    it 'creates and returns a new item' do
      item = nil

      expect {
        item = dummy_class.create!(id: 5, name: 'Test5')
      }.to change { dummy_class.storage.count }.by(1)

      expect(item).to be_a(dummy_class)
      expect(dummy_class.storage[5].name).to eq('Test5')
    end

    it 'raises an error if the item is invalid' do
      expect { dummy_class.create!(id: 6) }.to raise_error(ActiveMemory::Errors::RecordInvalid)
    end
  end

  describe '.where' do
    it 'returns items that match the given attributes' do
      item1 = dummy_class.create!(id: 7, name: 'Test7')
      item2 = dummy_class.create!(id: 8, name: 'Test8')

      expect(dummy_class.where(name: 'Test7')).to include(item1)
      expect(dummy_class.where(name: 'Test7')).not_to include(item2)
    end
  end

  describe '#save' do
    it 'persists the item if it is valid' do
      dummy_instance = dummy_class.new(id: 9, name: 'Test9')
      dummy_instance.save
      expect(dummy_class.storage[9]).to eq(dummy_instance)
    end

    it 'returns false if the item is invalid' do
      dummy_instance = dummy_class.new(id: 10)
      expect(dummy_instance.save).to be_falsey
    end
  end

  describe '#save!' do
    it 'persists the item if it is valid' do
      dummy_instance = dummy_class.new(id: 11, name: 'Test11')

      expect { dummy_instance.save! }.not_to raise_error
      expect(dummy_class.storage[11]).to eq(dummy_instance)
    end

    it 'raises an error if the item is invalid' do
      expect { dummy_class.new(id: 12).save! }.to raise_error(ActiveMemory::Errors::RecordInvalid)
    end
  end
end
