class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable and :omniauthable
  devise :database_authenticatable, :confirmable, :registerable,
         :recoverable, :rememberable, :timeoutable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :perm_site_admin, :perm_create_talk

  validates :name, :presence => true

  def name_and_email
    "#{name} &lt;#{email}&gt;".html_safe
  end

  def email_and_name
    "#{email} (#{name})".html_safe
  end
end
