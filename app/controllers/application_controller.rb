class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def require_site_admin
    authorize! :site_admin, :all
  end

  def do_subscription(subscribable, kind)
    s = subscribable.subscription(current_user)
    return unless ["subscribe", "watch", "unsubscribe"].include? (kind)
    if s then
      case kind
      when "subscribe"
        s.kind = "kind_subscriber"
        s.save
      when "watch"
        s.kind = "kind_watcher"
        s.save
      when "unsubscribe"
        s.destroy
      end
    else
      case kind
      when "subscribe"
        s = Subscription.new(:subscribable => subscribable, :user => current_user, :kind => "kind_subscriber")
        s.save
      when "watch"
        s = Subscription.new(:subscribable => subscribable, :user => current_user, :kind => "kind_watcher")
        s.save
      end
    end
  end

  # turn a list of talks into a calendar
  def generate_ical(talks)
    coder = HTMLEntities.new
    cal = RiCal.Calendar do |cal|
      talks.each do |t|
        cal.event do |event|
          event.summary = "#{t.speaker} - #{t.title}"
          event.dtstart = t.start_time.in_time_zone("US/Eastern")
          event.dtend = t.end_time.in_time_zone("US/Eastern")
          if t.room && t.building
            event.location = "#{t.room} #{t.building.abbrv}"
          elsif t.room
            event.location = t.room
          end
	        event.url = talk_url(t)
          # notes = ""
          # unless t.abstract.empty?
	        #    notes = coder.decode(ActionController::Base.helpers.strip_tags(t.abstract))
          # else
	        #    notes = "(No abstract yet)"
	        # end
	        # unless t.bio.empty?
	        #    notes << "Bio: " << coder.decode(ActionController::Base.helpers.strip_tags(t.bio))
	        # end
	        # event.description = notes
        end
      end
    end
  end

  def fix_range(params)
    params[:range] = :current unless params[:range]
    params[:range] = params[:range].to_sym
  end


  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :organization])
  end

end
