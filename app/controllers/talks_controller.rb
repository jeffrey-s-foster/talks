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
      redirect_to @talk
    else
      compute_edit_fields
      render :action => "edit"
    end
  end

  def edit
    @talk = Talk.find(params[:id])
    authorize! :edit, @talk
    compute_edit_fields
  end

  def update
    @talk = Talk.find(params[:id])
    authorize! :edit, @talk
    adjust params
    if @talk.update_attributes(params[:talk])
      redirect_to @talk
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
        logger.debug "Saved #{r.inspect}"
      end
    when "unregister"
      r[0].destroy if r[0]
    end
    respond_to do |format|
      format.js { render "shared/_update_badges.js.erb", :locals => { :subscribable => t } }
      format.html { redirect_to action: "show" }
    end
  end

  def cancel_registration
    r = Registration.find(params[:id])
    authorize! :edit, r.talk
    r.destroy
    redirect_to :show_registrations_talk
  end

  def show_registrations
    @talk = Talk.find(params[:id])
    authorize! :edit, @talk
    @regs = @talk.registrations
  end

  def calendar
    @talk = Talk.find(params[:id])
    respond_to do |format|
      format.ics { render :text => (generate_ical [@talk]) }
    end
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
      errors.add(nil, "Malformed date or time") if not (params[:talk][:start_time] && params[:talk][:end_time])
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
