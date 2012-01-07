class UsersController < ApplicationController
  def show
    @upcoming = not(params[:all])
    @list_subscriptions = Hash[current_user.subscribed_lists]
    @lists = (current_user.owned_lists + current_user.poster_lists + @list_subscriptions.keys).sort { |a,b| a.name <=> b.name }.uniq
    @talk_subscriptions = current_user.subscribed_talks(params[:all])
    if @upcoming then
      @talks = current_user.owned_talks.upcoming
    else
      @talks = current_user.owned_talks
    end
    @talks += @talk_subscriptions.keys
    @talks.sort! { |a,b| a.start_time <=> b.start_time }.uniq!
  end

# if params[:user][:password].blank?
#   params[:user].delete(:password)
#   params[:user].delete(:password_confirmation)
# end

end
