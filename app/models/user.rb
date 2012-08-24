class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable and :omniauthable
  devise :database_authenticatable, :confirmable, :registerable,
         :recoverable, :rememberable, :timeoutable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :perm_site_admin, :perm_create_talk, :organization, :opt_email_today, :opt_email_this_week

  has_many :owned_talks, :class_name => "Talk", :foreign_key => "owner_id"
  has_and_belongs_to_many :owned_lists, :foreign_key => "owner_id", :association_foreign_key => "owned_list_id", :join_table => "lists_owners", :class_name => "List"
  has_and_belongs_to_many :poster_lists, :foreign_key => "poster_id", :association_foreign_key => "poster_list_id", :join_table => "lists_posters", :class_name => "List"
  has_many :subscriptions
  has_many :registrations

  validates :email, :presence => true, :uniqueness => true
  validates :name, :presence => true

  def name_and_email
    "#{name} &lt;#{email}&gt;".sanitize
  end

  def email_and_name
    "#{email} (#{name})".sanitize
  end

  # TODO: check performance
  def subscribed_lists
    subscriptions.where(:subscribable_type => "List").map { |s| [List.find(s.subscribable_id), s.kind] }
  end

  # TODO: check performance
  # Returns hash table mapping talks to subscription kind (:kind_subscriber{_through} or :kind_watcher{_through})
  # range may be :all, :today, :this_week, :upcoming, :current
  def subscribed_talks(range, filter = [:kind_subscriber, :kind_subscriber_through, :kind_watcher, :kind_watcher_through])
    raise "Argument #{range.inspect} out of range" unless [:past, :today, :this_week, :upcoming, :current, :all].member? range
    talks = {} # map from talk to kind

    # directly subscribed talks
    subscriptions
      .where(:subscribable_type => "Talk")
      .map do |s|
        t = Talk.find(s.subscribable_id)
        talks[t] = s.kind if (t.match_range range) && (filter.member? s.kind)
      end

    # subscriptions via lists, whicih take precedence over directly subscribing/watching
    subscribed_lists.each do |l,k|
      l.talks.each do |t|
        if t.match_range range then
          case k
          when :kind_subscriber
            talks[t] = :kind_subscriber_through if filter.member? :kind_subscriber_through
          when :kind_watcher
            talks[t] = :kind_watcher_through if (talks[t] != :kind_subscriber) && (filter.member? :kind_watcher_through)
          end
        end
      end
    end

    return talks
  end

end
