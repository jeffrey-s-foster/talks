class ListsController < ApplicationController
  def index
    @lists = List.all.sort { |a,b| a.name <=> b.name }
  end

  def show
    @list = List.find(params[:id])
    if params[:all]
      @talks = @list.talks.sort { |a,b| a.start_time <=> b.start_time }
    else
      @talks = @list.talks.upcoming { |a,b| a.start_time <=> b.start_time }
    end
    @upcoming = !(params[:all])
  end

  def new
    authorize! :create, List
    @list = List.new
    @title = "Create new list"
    @owners = []
    @posters = []
    @users = User.all.sort { |a,b| a.email_and_name <=> b.email_and_name }
    render :action => "edit"
  end

  def edit
    authorize! :edit, List
    @list = List.find(params[:id])
    compute_edit_fields
  end

  def create
    authorize! :create, List
    adjust params
    @list = List.new(params[:list])

    if @list.save
      redirect_to @list, notice: 'List was successfully created.'
    else
      compute_edit_fields
      render action: "edit"
    end
  end

  def update
    authorize! :edit, List
    @list = List.find(params[:id])
    adjust params
    if not (can? :edit_name, @list) then
      params[:list].delete :name
    end

    if @list.update_attributes(params[:list])
      redirect_to @list, notice: 'List was successfully updated.'
    else
      compute_edit_fields
      render action: "edit"
    end
  end

  def destroy
    authorize! :destroy, List
    @list = List.find(params[:id])
    @list.destroy

    redirect_to lists_url
  end

  def subscribe
    l = List.find(params[:id])
    do_subscription(l, params[:do])
    respond_to do |format|
      format.js { render "shared/_update_badges.js.erb", :locals => { :subscribable => l } }
      format.html { redirect_to action: "show" }
    end
  end

  def feed
    l = List.find(params[:id])
    respond_to do |format|
      format.ics { render :text => (generate_ical l.talks) }
    end
  end

private

  def adjust(params)
    owners = []
    params.each_pair { |k,v|
      next unless k =~ /owner_(\d+)/
      next if v == ""
      owners << User.find(v)
    }
    params[:list][:owners] = owners

    posters = []
    params.each_pair { |k,v|
      next unless k =~ /poster_(\d+)/
      next if v == ""
      posters << User.find(v)
    }
    params[:list][:posters] = posters
  end

  def compute_edit_fields
    @title = "Edit list"
    @owners = @list.owners.sort { |a,b| a.email_and_name <=> b.email_and_name }
    @posters = @list.posters.sort { |a,b| a.email_and_name <=> b.email_and_name }
    @users = User.all.sort { |a,b| a.email_and_name <=> b.email_and_name }
  end
end
