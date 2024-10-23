# frozen_string_literal: true

class UniquenessValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    records = if options[:scope]
      record.class.where(attribute => value,
                         options[:scope] => record.send(options[:scope])
      )
    else
      record.class.where(attribute => value)
    end

    if records.any? { |device| device != record }
      record.errors.add(attribute, :taken)
    end
  end
end
