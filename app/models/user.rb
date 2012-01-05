class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable and :omniauthable
  devise :database_authenticatable, :confirmable, :registerable,
         :recoverable, :rememberable, :timeoutable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :perm_site_admin, :perm_create_talk

  has_many :owned_talks, :class_name => "Talk", :foreign_key => "owner_id"
  has_and_belongs_to_many :owned_lists, :foreign_key => "owner_id", :association_foreign_key => "owned_list_id", :join_table => "lists_owners", :class_name => "List"
  has_and_belongs_to_many :poster_lists, :foreign_key => "poster_id", :association_foreign_key => "poster_list_id", :join_table => "lists_posters", :class_name => "List"
  has_many :subscriptions

  validates :name, :presence => true

  def name_and_email
    "#{name} &lt;#{email}&gt;".html_safe
  end

  def email_and_name
    "#{email} (#{name})".html_safe
  end

  # TODO: check performance
  def subscribed_lists
    subscriptions.where(:subscribable_type => "List").map { |s| [List.find(s.subscribable_id), s.kind] }
  end

  # TODO: check performance
  # DIRECTLY subscribed talks only
  def subscribed_talks(include_past = false)
    subscriptions
      .where(:subscribable_type => "Talk")
      .map { |s|
        t = Talk.find(s.subscribable_id)
        if include_past || t.upcoming? then [t, s.kind] else nil end
       }
      .compact
  end

  # TODO: check performance
  # talks subscribed directly and via lists; INCLUDES directly subscribed talks; DOES NOT include owned talks
  def subscribed_talks_all(include_past = false)
    lists = subscribed_lists_all
    talks = {} # map from talk to kind
    lists.map { |l,k|
      k = :kind_full if k == :kind_owner # owners subscribe fully to all talks on their lists
      l.talks.each { |t|
        if include_past || t.upcoming? then
          talks[t] = Talk.lub_kinds(talks[t], k) # talks[t] == nil if t not present
        end
      }
    }
    subscribed_talks(include_past).each { |t,k|
      talks[t] = Talk.lub_kinds(talks[t], k) # talks[t] == nil if t not present
    }
    owned_talks.each { |t|
      talks[t] = Talk.lub_kinds(talks[t], :kind_owned)
    }
    talks.to_a.sort { |a,b| a[0].title <=> b[0].title }
  end

  def subscribed_lists_all
    lists = {} # map from list to kind
    subscribed_lists.map { |l,k| lists[l] = List.lub_kinds(lists[l], k) }
    poster_lists.map { |l| lists[l] = List.lub_kinds(lists[l], :kind_poster) }
    owned_lists.map { |l| lists[l] = List.lub_kinds(lists[l], :kind_owned) }
    lists.to_a.sort { |a,b| a[0].name <=> b[0].name }
  end
end
