class SessionsController < ApplicationController
  layout 'doorway'

  def index
    redirect_to root_path
  end
  
  def show
    redirect_to root_path
  end
 
  def new
    redirect_to tasks_path if current_user
  end
 
	def create
		if authenticate!
		  redirect_to tasks_path
		else
		  redirect_to root_path
		end
	end
  
  def edit
    redirect_to root_path
  end
  
  def update
    redirect_to root_path
  end
  
	def destroy
    session[:current_user] = nil
    cookies.delete(:remember_me) if cookies[:remember_me]
    
    redirect_to root_path
	end
end