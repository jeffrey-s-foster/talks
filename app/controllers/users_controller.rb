class UsersController < ApplicationController
  def show
    @user = current_user
    @owned_lists = @user.owned_lists.sort { |a,b| a.name <=> b.name }
    @poster_lists = @user.poster_lists.sort { |a,b| a.name <=> b.name }
    # TODO: next lines are yucky
    @subscribed_lists = @user.subscribed_lists_full
    @subscribed_talks = @user.subscribed_talks_full
  end

# if params[:user][:password].blank?
#   params[:user].delete(:password)
#   params[:user].delete(:password_confirmation)
# end

end
