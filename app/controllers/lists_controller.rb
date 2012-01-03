class ListsController < ApplicationController
  def index
    @lists = List.all.sort { |a,b| a.name <=> b.name }
  end

  # Show upcoming talks (TODO)
  def show
    @list = List.find(params[:id])
    @talks = @list.talks.upcoming
    @upcoming = true
  end

  def show_all
    @list = List.find(params[:id])
    @talks = @list.talks.sort { |a,b| a.start_time <=> b.start_time }
    @upcoming = false
    render :action => "show"
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
    @title = "Edit list"
    @owners = @list.owners.sort { |a,b| a.email_and_name <=> b.email_and_name }
    @posters = @list.posters.sort { |a,b| a.email_and_name <=> b.email_and_name }
    @users = User.all.sort { |a,b| a.email_and_name <=> b.email_and_name }
  end

  def create
    authorize! :create, List
    adjust params
    @list = List.new(params[:list])

    if @list.save
      redirect_to @list, notice: 'List was successfully created.'
    else
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
    # TODO: This code is yucky!
   @subscription = Subscription.where(:subscribable_id => params[:id], :subscribable_type => "List", :user_id => current_user.id)
   case @subscription.length
   when 0
     @subscription = Subscription.new
   when 1
     @subscription = @subscription.first
   else
     logger.error "Multiple subscriptions: subscribable_id = #{params[:id]}, subscribable_type = List, user_id = #{current_user.id}"
     render :template => "500.html"
   end
   @subscription.subscribable = List.find(params[:id])
   @subscription.user = current_user
   @subscription.kind = :kind_full
   @subscription.save
    respond_to do |format|
      format.js { }
      format.html { redirect_to action: "show" }
    end
  end

  def unsubscribe
    @list = List.find(params[:id])
    @list.subscribers.delete(current_user)
    respond_to do |format|
      format.js { }
      format.html { redirect_to action: "show" }
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
end
