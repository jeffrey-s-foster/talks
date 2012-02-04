class List < ActiveRecord::Base
  validates_presence_of :name

  has_and_belongs_to_many :talks
  has_and_belongs_to_many :owners, :foreign_key => "owned_list_id", :association_foreign_key => "owner_id", :join_table => "lists_owners", :class_name => "User"
  has_and_belongs_to_many :posters, :foreign_key => "poster_list_id", :association_foreign_key => "poster_id", :join_table => "lists_posters", :class_name => "User"
  has_many :subscriptions, :as => :subscribable, :include => :user
  has_many :subscribers, :through => :subscriptions, :class_name => "User", :source => :user

  def subscription(user)
    s = Subscription.where(:subscribable_id => id, :subscribable_type => "List", :user_id => user.id)
    return nil if s.length == 0
    return s.first if s.length == 1
    logger.error "Multiple subscriptions #{s}"
    return nil
  end

  def owner?(user)
    return owners.include? user
  end

  def poster?(user)
    return posters.include? user
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
