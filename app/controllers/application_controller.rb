class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def require_site_admin
    authorize! :site_admin, :all
  end

  def do_subscription(subscribable, kind)
    s = subscribable.subscription(current_user)
    return unless ["subscribe", "watch", "unsubscribe"].include? (kind)
    if s then
      case kind
      when "subscribe"
        s.kind = :kind_subscriber
        s.save
      when "watch"
        s.kind = :kind_watcher
        s.save
      when "unsubscribe"
        s.destroy
      end
    else
      case kind
      when "subscribe"
        s = Subscription.new(:subscribable => subscribable, :user => current_user, :kind => :kind_subscriber)
        s.save
      when "watch"
        s = Subscription.new(:subscribable => subscribable, :user => current_user, :kind => :kind_watcher)
        s.save
      end
    end
  end

end
