class SessionsController < ApplicationController
  layout 'doorway'

  def index
    redirect_to root_path
  end
  
  def show
    redirect_to root_path
  end
 
  def new
    dredirect_to('project.tasks', :project_id => Project.first.id) if current_user
  end
 
	def create
		if authenticate!
		  dredirect_to('project.tasks', :project_id => Project.first.id)
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
    session[:task_options] = nil
    cookies.delete(:remember_me) if cookies[:remember_me]
    
    redirect_to root_path
	end
end