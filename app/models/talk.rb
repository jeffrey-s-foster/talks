class Talk < ActiveRecord::Base
  validate :start_end_same_day
  validate :start_end_not_error

  def start_end_same_day
    if start_time && end_time && (start_time.to_date != end_time.to_date)
      errors.add(:internal, "Internal error - start time and end time must be on same day")
    end
  end

  def start_end_not_error
    errors.add(:start_time, "- Invalid start time") if not start_time
    errors.add(:end_time, "- Invalid end time") if not end_time
  end
end
