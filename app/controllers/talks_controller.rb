class TalksController < ApplicationController

  def upcoming
    @talks = Talk.upcoming.sort { |a,b| a.start_time <=> b.start_time }
    fix_range params
    if current_user
      @talk_subscriptions = current_user.subscribed_talks(params[:range])
    else
      @talk_subscriptions = Hash.new
    end
  end

  def index
    authorize! :site_admin, :all
    @talks = Talk.all
  end

  def new
    authorize! :create, Talk
    @talk = Talk.new
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
  end

  def create
    authorize! :create, Talk
    adjust params
    @talk = Talk.new(params[:talk])
    @talk.owner = current_user unless can? :edit_owner, @talk
    logger.info "Start_time: #{params[:talk][:start_time]}"
    logger.info "End_time: #{params[:talk][:end_time]}"
    if @talk.save
      if params[:talk][:trigger_watch_email] == "1"
        @talk.delay.email_watchers(nil)
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
    @talk.trigger_watch_email = true
  end

  def update
    @talk = Talk.find(params[:id])
    @talk_old = @talk.dup
    authorize! :edit, @talk
    adjust params
    if @talk.update_attributes(params[:talk])
      if params[:talk][:trigger_watch_email] == "1"
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
          @talk.delay.email_watchers(changes)
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
    authorize! :edit, @talk
    @regs = @talk.registrations
    @users = User.all.sort { |a,b| a.email_and_name <=> b.email_and_name }
  end

  def add_registrations
    authorize! :site_admin, :all
    t = Talk.find(params[:id])
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
    r.destroy
    redirect_to show_registrations_talk_path(t)
  end

  def external_register
    @talk = Talk.find(params[:id])
    @reg = Registration.new(:talk_id => @talk.id,
                            :user_id => 0,
                            :name => params[:name],
                            :email => params[:email],
                            :organization => params[:organization],
                            :secret => SecureRandom.base64,
                            )
    if @reg.save
      Notifications.send_external_reg(@reg).deliver
    else
      render :action => :show
    end
  end

  def cancel_external_registration
    @reg = Registration.find(params[:registration])
    if @reg && (@reg.secret == params[:secret])
      @reg.destroy
      @success = true
    else
      @success = false
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
    params[:talk][:lists] = lists
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
