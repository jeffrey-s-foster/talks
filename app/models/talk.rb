class Talk < ActiveRecord::Base
  validate :start_end_same_day

  def start_end_same_day
    if start_time && end_time && (start_time.to_date != end_time.to_date)
      errors.add(:end, "internel error - start time and end time must be on same day")
    end
  end
end
