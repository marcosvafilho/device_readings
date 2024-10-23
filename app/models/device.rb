class Device < ApplicationMemory
  attribute :id, :string

  validates :id,
            presence: true,
            uniqueness: true
end
