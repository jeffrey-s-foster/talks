class AdminController < ApplicationController
  before_filter :require_site_admin

  def index
  end

  def spam
  end

  def send_spam
#    AdminController.delay.spam_users(:subject => params[:subject], :message => params[:message])
    redirect_to admin_index_path, :notice => "Sending message to all users..."
  end

  def self.spam_users(h)
    User.all.each do |u|
      if u.confirmed_at
        Notifications.send_admin_message(u, h).deliver
      end
    end
    logger.debug "Messages delivered."
  end

#  def erase_subscriptions
#    Subscription.destroy_all
#    redirect_to admin_index_path
#  end
end
