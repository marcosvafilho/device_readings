# frozen_string_literal: true

class DatetimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.is_a?(DateTime) || value.is_a?(Time)
      record.errors.add(attribute, "must be a valid date-time string")
    end
  end
end
