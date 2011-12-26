class TalksController < ApplicationController
  def index
    @talks = Talk.all
  end

  def new
    @talk = Talk.new
    @title = "Create new talk"
    render :action => "edit"
  end

  def show
    @talk = Talk.find(params[:id])
    if @talk.start_time && @talk.end_time
      @time = (@talk.start_time.strftime "%A, %B %-d, %Y, ") + (@talk.start_time.strftime("%l:%M").lstrip)
      if ((@talk.start_time.hour < 12) == (@talk.end_time.hour < 12)) # both am or both pm
        @time << "-" << (@talk.end_time.strftime("%l:%M %P").lstrip)
      else
        @time << (@talk.start_time.strftime " %P-") << (@talk.end_time.strftime("%l:%M %P").lstrip)
      end
    else
      @time = "(Time not yet available)"
    end
  end

  def create
    adjust params
    @talk = Talk.new(params[:talk])
    logger.info "Start_time: #{params[:talk][:start_time]}"
    logger.info "End_time: #{params[:talk][:end_time]}"
    if @talk.save
      redirect_to @talk
    else
      render :action => "edit"
    end
  end

  def edit
    @talk = Talk.find(params[:id])
    @title = "Edit talk"
    if @talk.start_time && @talk.end_time
      @date = @talk.start_time.strftime("%m/%d/%Y")
      @start_time = @talk.start_time.strftime("%l:%M %P").lstrip
      @end_time = @talk.end_time.strftime("%l:%M %P").lstrip
    end
  end

  def update
    @talk = Talk.find(params[:id])
    adjust params
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
    @talk.destroy
    redirect_to talks_path
  end

private

  def adjust(params)
    if params[:temp_date_time] != "" then
      # TODO: handle parsing errors here
      if params[:temp_date_time] =~ /(.*) from (.*) to (.*)/ then
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
  end

end
