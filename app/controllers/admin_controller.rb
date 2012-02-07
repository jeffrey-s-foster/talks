class AdminController < ApplicationController
  before_filter :require_site_admin

  def index
  end

  def erase_subscriptions
    Subscription.destroy_all
    redirect_to admin_index_path
  end
end
