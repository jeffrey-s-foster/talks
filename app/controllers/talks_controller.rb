class TalksController < ApplicationController

  def index
    fix_range params
    if params[:range] == :past
      @talks = Talk.past.sort { |a,b|
        [b.start_time.beginning_of_day, a.start_time] <=> [a.start_time.beginning_of_day, b.start_time]
      }
      @current = false
    elsif params[:range] == :all
      @talks = Talk.all_recent.sort { |a,b| a.start_time <=> b.start_time }
    else
      @talks = Talk.current.sort { |a,b| a.start_time <=> b.start_time }
      @current = true
    end
    @lists = List.all.sort { |a,b| a.name <=> b.name }
    respond_to do |format|
      format.html
      format.json
    end
end

  def admin_view
    authorize! :site_admin, :all
    @talks = Talk.all
  end

  def new
    authorize! :create, Talk
    @talk = Talk.new(:kind => :standard)
    @title = "Create new talk"
    @posted = []
    @talk.owner = current_user
    if can? :site_admin, :all then
      @lists = List.all.sort { |a,b| a.name <=> b.name }
    else
      @lists = (current_user.owned_lists + current_user.poster_lists).sort { |a,b| a.name <=> b.name }.uniq
    end
    @talk.trigger_watch_email = true
    render :action => "edit"
  end

  def show
    @talk = Talk.find(params[:id])
    @subscription = @talk.subscription current_user if current_user
    @lists = List.all.sort { |a,b| a.name <=> b.name }
    respond_to do |format|
      format.html
      format.json
    end
  end

  def create
    authorize! :create, Talk
    talk_params, lists = adjust params
    @talk = Talk.new(talk_params)
    @talk.lists = lists
    @talk.owner = current_user unless can? :edit_owner, @talk
    if @talk.save
      if params[:talk][:trigger_watch_email] == "1"
#        @talk.delay.email_watchers(nil)
        redirect_to @talk, :notice => "Sending talk creation notification to subscribers and watchers..."
      else
        redirect_to @talk
      end
    else
      compute_edit_fields
      render :action => "edit"
    end
  end

  def edit
    @talk = Talk.find(params[:id])
    authorize! :edit, @talk
    compute_edit_fields
    @talk.trigger_watch_email = false
  end

  def update
    @talk = Talk.find(params[:id])
    @talk_old = @talk.dup
    authorize! :edit, @talk
    talk_params, lists = adjust params
    @talk.lists = lists
    if @talk.update(talk_params)
      if talk_params[:trigger_watch_email] == "1"
        changes = Set.new
        changes << :title if @talk_old.title != @talk.title
        changes << :speaker if ((@talk_old.speaker != @talk.speaker) || (@talk_old.speaker_url != @talk.speaker_url))
        changes << :venue if ((@talk_old.room != @talk.room) || (@talk_old.building != @talk.building))
        changes << :time if ((@talk_old.start_time != @talk.start_time) || (@talk_old.end_time != @talk.end_time))
        changes << :abstract if (@talk_old.abstract != @talk.abstract)
        changes << :bio if (@talk_old.bio != @talk.bio)
        changes << :reg if (@talk_old.request_reg != @talk.request_reg)
        if changes.empty?
          redirect_to @talk
        else
#          @talk.delay.email_watchers(changes)
          redirect_to @talk, :notice => "Sending talk update notification to subscribers and watchers..."
        end
      else
        redirect_to @talk
      end
    else
      compute_edit_fields
      render :action => "edit"
    end
  end

  def destroy
    @talk = Talk.find(params[:id])
    authorize! :edit, @talk
    @talk.destroy
    redirect_to talks_path
  end

  def subscribe
    t = Talk.find(params[:id])
    do_subscription(t, params[:do])
    respond_to do |format|
      format.js { render "shared/_update_badges.js.erb", :locals => { :subscribable => t } }
      format.html { redirect_to action: "show" }
    end
  end

  def register
    t = Talk.find(params[:id])
    r = Registration.where(:talk_id => t, :user_id => current_user)
    raise "Attempt to register for talk without registration" if not t.request_reg
    logger.error "Inconsistency, r is #{r}" if r.length > 1
    case params[:do]
    when "register"
      if r.empty?
        r = Registration.new(:talk_id => t.id, :user_id => current_user.id)
        r.save
      end
    when "unregister"
      r[0].destroy if r[0]
    end
    respond_to do |format|
      format.js { render "shared/_update_badges.js.erb", :locals => { :subscribable => t } }
      format.html { redirect_to action: "show" }
    end
  end

  def show_registrations
    @talk = Talk.find(params[:id])
    raise "Attempt to register for talk without registration" if not @talk.request_reg
    authorize! :edit, @talk
    @regs = @talk.registrations
    @users = User.all.sort { |a,b| a.email_and_name <=> b.email_and_name }
    if params[:csv] == "true"
      render :show_registrations_csv, :layout => false, :content_type => "text/csv"
    end
  end

  def add_registrations
    authorize! :site_admin, :all
    t = Talk.find(params[:id])
    raise "Attempt to register for talk without registration" if not t.request_reg
    params.each_pair { |k,v|
      next unless k =~ /user_(\d+)/
      next if v == ""
      u = User.find v
      if Registration.where(:talk_id => t, :user_id => u).empty?
        r = Registration.new(:talk_id => t.id, :user_id => u.id)
        r.save
      end
    }
    redirect_to show_registrations_talk_path(t)
  end

  def cancel_registration
    r = Registration.find(params[:id])
    t = r.talk
    authorize! :edit, r.talk
#    raise "Attempt to register for talk without registration" if not t.request_reg
    r.destroy
    redirect_to show_registrations_talk_path(t)
  end

  def external_register
    @talk = Talk.find(params[:id])
    raise "Attempt to register for talk without registration" if not @talk.request_reg
    @reg = Registration.new(:talk_id => @talk.id,
                            :user_id => 0,
                            :name => params[:name],
                            :email => params[:email],
                            :organization => params[:organization],
                            :secret => SecureRandom.base64,
                            )
    if @reg.save
      TheMailer.send_external_reg(@reg).deliver_now
    else
      render :action => :show
    end
  end

  def cancel_external_registration
    @reg = Registration.find(params[:registration])
    if @reg && (@reg.secret == params[:secret])
      @reg.destroy
      @success = true
      TheMailer.send_cancel_reg(@reg).deliver_now
    else
      @success = false
    end
  end

  def feed
    @talks = Talk.all_recent.sort { |a,b| a.start_time <=> b.start_time }
    @title = t :site_name
    respond_to do |format|
      format.ics { render :text => (generate_ical @talks) }
      format.atom { render "shared/feed", :layout => false  }
    end
  end

  def calendar
    @talk = Talk.find(params[:id])
    respond_to do |format|
      format.ics { render :text => (generate_ical [@talk]) }
    end
  end

  def show_subscribers
    authorize! :site_admin, :all
    @talk = Talk.find(params[:id])
    @subscribers = []
    @subscribers += @talk.subscribers
    @subscribers += (@talk.lists.map { |l| l.subscribers }).flatten
    @subscribers.sort! { |a,b| a.email_and_name <=> b.email_and_name }
    render "shared/show_subscribers"
  end

  def feedback
    @lists = List.all.sort { |a,b| a.name <=> b.name }
  end

  def receive_feedback
    TheMailer.send_feedback(:name => params[:name].truncate(255), :email => params[:email].truncate(255), :subject => params[:subject].truncate(255), :comments => params[:comments].truncate(5000)).deliver_now
    redirect_to root_path, :notice => "Thank you for your feedback"
  end

private

  def adjust(params)
    if params[:temp_date_time] != "" then
      # TODO: handle parsing errors here
      if (params[:temp_date_time] =~ /(.*) from (.*) to (.*)/) || (params[:temp_date_time] =~ /(.*) from (.*)\s*-\s*(.*)/) then
        params[:talk][:start_time] = Chronic.parse("#{$1} at #{$2}")
        params[:talk][:end_time] = Chronic.parse("#{$1} at #{$3}")
      else
        params[:talk][:start_time] = params[:talk][:end_time] = nil
      end
    else
      params[:talk][:start_time] = Chronic.parse("#{params[:temp_date]} #{params[:temp_start_time]}")
      params[:talk][:end_time] = Chronic.parse("#{params[:temp_date]} #{params[:temp_end_time]}")
#      errors.add(nil, "Malformed date or time") if not (params[:talk][:start_time] && params[:talk][:end_time])
    end

    lists = []
    params.each_pair { |k,v|
      next unless k =~ /posted_(\d+)/
      next if v == ""
      l = List.find v
      next unless can? :add_talk, l
      lists << l
    }

    return params.require(:talk).permit(:title, :speaker, :speaker_affiliation,
      :speaker_url, :room, :building_id, :kind, :request_reg,
      :trigger_watch_email, :owner_id, :abstract, :bio,
      :reg_info, :start_time, :end_time), lists
#    params.require(:talk).permit!
  end

  def compute_edit_fields
    @title = "Edit talk"
    if @talk.start_time && @talk.end_time
      @date = @talk.start_time.strftime("%m/%d/%Y")
      @start_time = @talk.start_time.strftime("%l:%M %P").lstrip
      @end_time = @talk.end_time.strftime("%l:%M %P").lstrip
    end
    @posted = @talk.lists
    if can? :site_admin, :all then
      @lists = List.all.sort { |a,b| a.name <=> b.name }
    else
      @lists = (current_user.owned_lists + current_user.poster_lists).sort { |a,b| a.name <=> b.name }.uniq
    end
  end

end
