class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable and :omniauthable
  devise :database_authenticatable, :confirmable, :registerable,
         :recoverable, :rememberable, :timeoutable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :perm_site_admin, :perm_create_talk

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

  def subscribed_lists
    subscriptions.where(:subscribable_type => "List").map { |s| [List.find(s.subscribable_id), s.kind] }
  end

  def subscribed_talks
    subscriptions.where(:subscribable_type => "Talk").map { |s| [Talk.find(s.subscribable_id), s.kind] }
  end
end
