class UsersController < ApplicationController
  def show
    @lists = current_user.subscribed_lists_all
    @talks = current_user.subscribed_talks_all
  end

# if params[:user][:password].blank?
#   params[:user].delete(:password)
#   params[:user].delete(:password_confirmation)
# end

end
