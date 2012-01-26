class Admin::UsersController < ApplicationController
  before_filter :require_site_admin

  def index
    @users = User.all.sort { |a,b| a.email <=> b.email }
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if params[:user][:password] == "" then
      params[:user].delete :password
    end
    if @user.update_attributes(params[:user])
      redirect_to admin_users_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admin_users_path
  end

  def reset_ical_secret
    @user = User.find(params[:id])
    @user.update_attribute(:ical_secret, nil)
    redirect_to admin_users_path, :notice => "ical secret reset for #{@user.email}"
  end

end
