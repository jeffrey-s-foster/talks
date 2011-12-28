class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def require_site_admin
    authorize! :site_admin, :all
  end
end
