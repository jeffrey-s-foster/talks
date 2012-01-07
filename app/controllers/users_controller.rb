class UsersController < ApplicationController
  def show
    @upcoming = not(params[:all])
    @list_subscriptions = Hash[current_user.subscribed_lists]
    @lists = (current_user.owned_lists + current_user.poster_lists + @list_subscriptions.keys).sort { |a,b| a.name <=> b.name }.uniq
    @talks = current_user.subscribed_talks(params[:all])
  end

# if params[:user][:password].blank?
#   params[:user].delete(:password)
#   params[:user].delete(:password_confirmation)
# end

end
