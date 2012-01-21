class UsersController < ApplicationController

  before_filter :generate_ical_secret

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

  # TODO: add security
  # Note that this can't require the user to log in...
  def feed
    user = User.find(params[:id])
    @talks = user.subscribed_talks(true).to_a.map { |k,v| if (v == :kind_subscriber || v == :kind_subscriber_through) then k else nil end}.compact
    respond_to do |format|
      if params[:key] == user.ical_secret
        format.ics { render :text => (generate_ical @talks) }
      else
        format.ics { render :nothing => true, :status => :forbidden }
      end
    end
  end

# if params[:user][:password].blank?
#   params[:user].delete(:password)
#   params[:user].delete(:password_confirmation)
# end

private

  def generate_ical_secret
    if current_user && (current_user.ical_secret == nil || current_user.ical_secret == "") then
      current_user.update_attribute(:ical_secret, SecureRandom.base64)
    end
    true
  end

end
