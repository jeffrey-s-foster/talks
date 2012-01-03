class UsersController < ApplicationController
  def show
    @user = current_user
    @owned_lists = @user.owned_lists.sort { |a,b| a.name <=> b.name }
    @poster_lists = @user.poster_lists.sort { |a,b| a.name <=> b.name }
    # TODO: next lines are yucky
    @subscribed_lists = @user.subscriptions.where(:subscribable_type => "List").map { |s| List.find(s.subscribable_id) }
    @subscribed_talks = @user.subscriptions.where(:subscribable_type => "Talk").map { |s| Talk.find(s.subscribable_id) }
  end

# if params[:user][:password].blank?
#   params[:user].delete(:password)
#   params[:user].delete(:password_confirmation)
# end

end
