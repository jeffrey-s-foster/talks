class Talk < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
  has_and_belongs_to_many :lists, :include => :subscriptions
  has_many :subscriptions, :as => :subscribable, :include => :user
  has_many :subscribers, :through => :subscriptions, :class_name => "User", :source => :user

  validate :start_end_same_day
  validate :start_end_not_error
  validate :start_less_than_end
  validates_presence_of :owner

  def start_end_same_day
    if start_time && end_time && (start_time.to_date != end_time.to_date)
      errors.add(:internal_error, "- start time and end time must be on same day")
    end
  end

  def start_end_not_error
    errors.add(:start_time, "- Invalid start time") if not start_time
    errors.add(:end_time, "- Invalid end time") if not end_time
  end

  def start_less_than_end
    errors.add(:end_time, "- End time must be greater than start time") if not (end_time > start_time)
  end

  def self.upcoming
    # use end_time so talks going on now still appear
    where("end_time > ?", Time.zone.now)
  end

  def upcoming?
    end_time > Time.zone.now
  end

  def time_to_long_s
    t = ""
    if start_time && end_time
      t = (start_time.strftime "%A, %B %-d, %Y, ") + (start_time.strftime("%l:%M").lstrip)
      if ((start_time.hour < 12) == (end_time.hour < 12)) # both am or both pm
        t << "-" << (end_time.strftime("%l:%M %P").lstrip)
      else
        t << (start_time.strftime " %P-") << (end_time.strftime("%l:%M %P").lstrip)
      end
    else
      t = "(Time not yet available)"
    end
    return t
  end

  # least upper bound of two kinds
  def self.lub_kinds(k1, k2)
    return :kind_owned if k1 == :kind_owned || k2 == :kind_owned
    return :kind_full if k1 == :kind_full || k2 == :kind_full
    return :kind_watch if k1 == :kind_watch || k2 == :kind_watch
    return nil if k1 == nil && k2 == nil
    logger.error "Asked for lub of kinds #{k1} and #{k2}"
    return nil
  end
end
