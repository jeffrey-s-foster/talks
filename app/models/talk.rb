class Talk < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
  has_and_belongs_to_many :lists, :include => :subscriptions
  has_many :subscriptions, :as => :subscribable, :include => :user
  has_many :subscribers, :through => :subscriptions, :class_name => "User", :source => :user
  belongs_to :building

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

  def subscription(user)
    s = Subscription.where(:subscribable_id => id, :subscribable_type => "Talk", :user_id => user.id)
    return nil if s.length == 0
    return s.first if s.length == 1
    logger.error "Multiple subscriptions #{s}"
    return nil
  end

  def owner?(user)
    return owner == user
  end

  def poster?(user)
    return false
  end

  def watcher?(user)
    s = subscription(user)
    return s && (s.kind == :kind_watcher)
  end

  def subscriber?(user)
    s = subscription(user)
    return s && (s.kind == :kind_subscriber)
  end

end
