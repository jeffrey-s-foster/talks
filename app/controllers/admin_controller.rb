class AdminController < ApplicationController
  before_filter :require_site_admin

  def index
  end
end
