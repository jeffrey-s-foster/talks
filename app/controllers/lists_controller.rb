class ListsController < ApplicationController
  def index
    @lists = List.all.sort { |a,b| a.name <=> b.name }
  end

  def show
    @list = List.find(params[:id])
  end

  def new
    authorize! :create, List
    @list = List.new
    @title = "Create new list"
    render :action => "edit"
  end

  def edit
    authorize! :edit, List
    @list = List.find(params[:id])
    @title = "Edit list"
    @owners = @list.owners.sort { |a,b| a.email_and_name <=> b.email_and_name }
    @users = User.all.sort { |a,b| a.email_and_name <=> b.email_and_name }
  end

  def create
    authorize! :create, List
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
end
