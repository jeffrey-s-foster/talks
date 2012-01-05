class List < ActiveRecord::Base
  validates_presence_of :name

  has_and_belongs_to_many :talks
  has_and_belongs_to_many :owners, :foreign_key => "owned_list_id", :association_foreign_key => "owner_id", :join_table => "lists_owners", :class_name => "User"
  has_and_belongs_to_many :posters, :foreign_key => "poster_list_id", :association_foreign_key => "poster_id", :join_table => "lists_posters", :class_name => "User"
  has_many :subscriptions, :as => :subscribable, :include => :user
  has_many :subscribers, :through => :subscriptions, :class_name => "User", :source => :user

  def self.subscription(list, user)
    s = Subscription.where(:subscribable_id => list.id, :subscribable_type => "List", :user_id => user.id)
    return nil if s.length == 0
    return s.first if s.length == 1
    logger.error "Multiple subscriptions #{s}"
    return nil
  end

  def subscription(user)
    return List.subscription(self, user)
  end

  def self.lub_kinds(k1, k2)
    return :kind_owned if k1 == :kind_owned || k2 == :kind_owned
    return :kind_poster if k1 == :kind_poster || k2 == :kind_poster
    return :kind_full if k1 == :kind_full || k2 == :kind_full
    return :kind_watch if k1 == :kind_watch || k2 == :kind_watch
    return nil if k1 == nil && k2 == nil
    logger.error "Asked for lub of kinds #{k1} and #{k2}"
    return nil
  end

end
