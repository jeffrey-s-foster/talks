class TalksController < ApplicationController

  def upcoming
    @talks = Talk.upcoming
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
      @posted = @talk.lists
      if can? :site_admin, :all then
        @lists = List.all.sort { |a,b| a.name <=> b.name }
      else
        @lists = (current_user.owned_lists + current_user.poster_lists).sort { |a,b| a.name <=> b.name }.uniq
      end
      render :action => "edit"
    end
  end

  def edit
    @talk = Talk.find(params[:id])
    authorize! :edit, @talk
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

  def update
    @talk = Talk.find(params[:id])
    authorize! :edit, @talk
    adjust params
#    @talk.owner = current_user # shouldn't just change the owner
    logger.info "Start_time: #{params[:talk][:start_time]}"
    logger.info "End_time: #{params[:talk][:end_time]}"
    if @talk.update_attributes(params[:talk])
      redirect_to @talk
    else
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
    # TODO: This code is yucky!
   @subscription = Subscription.where(:subscribable_id => params[:id], :subscribable_type => "Talk", :user_id => current_user.id)
   case @subscription.length
   when 0
     @subscription = Subscription.new
   when 1
     @subscription = @subscription.first
   else
     logger.error "Multiple subscriptions: subscribable_id = #{params[:id]}, subscribable_type = List, user_id = #{current_user.id}"
     render :template => "500.html"
   end
   @subscription.subscribable = Talk.find(params[:id])
   @subscription.user = current_user
   @subscription.kind = :kind_full
   @subscription.save
    respond_to do |format|
      format.js { }
      format.html { redirect_to action: "show" }
    end
  end

  def unsubscribe
    @talk = Talk.find(params[:id])
    @talk.subscribers.delete(current_user)
    respond_to do |format|
      format.js { }
      format.html { redirect_to action: "show" }
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

end
