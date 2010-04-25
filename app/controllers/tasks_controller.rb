class TasksController < ApplicationController
  before_filter :authenticated?, :init_section
  layout 'standard'
  
  def index
    @tasks = Task.all_from_section(@section, current_user, @archived)
  end
  
  def show
    @task = Task.first(:conditions => { :id => params[:id] })
    
    redirect_to tasks_path unless @task
  end
  
  def new
    @task = Task.new
  end
  
  def create
    @task = Task.new(params[:task])
    @task.created_by = current_user.id
    @task.project_id = current_project.id
    
    if @task.save
      @task.set_dates_from_params(params)
      redirect_to tasks_path
    else
      render :action => 'new'
    end
  end
  
  def edit
    @task = Task.find(params[:id])
  end
  
  def update
    @task = Task.find(params[:id])
    
    if @task.update_attributes(params[:task])
      @task.set_dates_from_params(params)
      redirect_to tasks_path
    else
      render :action => "edit"
    end
  end
  
  def destroy
    Task.find(params[:id]).destroy
    redirect_to tasks_path
  end
  
  def init_section
    if params[:section]
      session[:task_section] = params[:section] 
    elsif not session[:task_section]
      session[:task_section] = 'my_tasks'
    end
    
    @section = session[:task_section]
    
    if params[:archived]
      session[:task_archived] = (params[:archived] == '0' ? false : true) 
    elsif not session[:task_archived]
      session[:task_section] = false
    end
    @archived = session[:task_archived]
  end
end