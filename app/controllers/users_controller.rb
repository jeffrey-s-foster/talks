class UsersController < ApplicationController
  def show
    @user = current_user
  end

# if params[:user][:password].blank?
#   params[:user].delete(:password)
#   params[:user].delete(:password_confirmation)
# end

end
