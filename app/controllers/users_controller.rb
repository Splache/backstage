class UsersController < ApplicationController
  before_filter :authenticated?
  layout 'standard'

  def index
    @users = User.all
  end

  def show
    @user = User.first(:conditions => { :id => params[:id] })
  end

  def new
    @user = User.new
    @subscriptions = Subscription.build_for_recipient
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      Subscription.update_all_for_recipient(@user.id, params[:user][:subscriptions])
      redirect_to users_path
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
    @subscriptions = Subscription.build_for_recipient(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      Subscription.update_all_for_recipient(@user.id, params[:user][:subscriptions])
      redirect_to users_path
    else
      render :action => "edit"
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to users_path
  end
end
