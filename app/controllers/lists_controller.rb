class ListsController < ApplicationController
  def index
    @lists = List.all.sort { |a,b| a.name <=> b.name }
  end

  def show
    @list = List.find(params[:id])
  end

  def new
    @list = List.new
    @title = "Create new list"
    render :action => "edit"
  end

  def edit
    @list = List.find(params[:id])
    @title = "Edit talk"
  end

  def create
    @list = List.new(params[:list])

    if @list.save
      redirect_to @list, notice: 'List was successfully created.'
    else
      render action: "edit"
    end
  end

  def update
    @list = List.find(params[:id])

    if @list.update_attributes(params[:list])
      redirect_to @list, notice: 'List was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @list = List.find(params[:id])
    @list.destroy

    redirect_to lists_url
  end
end
