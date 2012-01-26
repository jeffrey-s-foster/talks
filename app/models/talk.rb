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
    errors.add(:end_time, "- End time must be greater than start time") if (start_time && end_time && (not (end_time > start_time)))
  end

  def self.upcoming
    # use end_time so talks going on now still appear
    where("end_time > ?", Time.zone.now)
  end

  def self.today
    where("end_time > ? and start_time < ?", Time.zone.now.beginning_of_day, Time.zone.now.end_of_day)
  end

  def self.this_week
    # In Rails 3.2, beginning/end_of_week take a start day parameter
    where("end_time > ? and start_time < ?", Time.zone.now.beginning_of_week - 1.day, Time.zone.now.end_of_week - 1.day)
  end

  def upcoming?
    end_time > Time.zone.now
  end

  def today?
    (end_time > Time.zone.now.beginning_of_day) && (start_time < Time.zone.now.end_of_day)
  end

  def this_week?
    (end_time > Time.zone.now.beginning_of_week - 1.day) && (start_time < Time.zone.now.end_of_week - 1.day)
  end

  # range may be :all, :today, :this_week, :upcoming
  def match_range(range)
    (range == :all) ||
      (range == :upcoming && upcoming?) ||
      (range == :today && today?) ||
      (range == :this_week && this_week?)
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

  def subscriber?(user)
    s = subscription(user)
    return s && (s.kind == :kind_subscriber)
  end

  def watcher?(user)
    s = subscription(user)
    return s && (s.kind == :kind_watcher)
  end

  # returns :nil, :kind_subscriber_through, or :kind_watcher_through
  def through(user)
    return nil unless user
    k = nil
    user.subscribed_lists.each do |l, kl|
      if l.talks.exists? self then
        if kl == :kind_subscriber
          k = :kind_subscriber_through
        elsif (kl == :kind_watcher) && (k != :kind_subscriber)
          k = :kind_watcher_through
        end
      end
    end
    return k
  end

end
