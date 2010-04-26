class TasksController < ApplicationController
  before_filter :authenticated?, :init_section
  layout 'standard'
  
  def index
    @tasks = Task.all_from_section(@section, current_user, @archived)
  end
  
  def show
    
  end
  
  def new
    template = Task.last(:order => 'id ASC')
    
    @task = current_project.tasks.build
    @task.nature = template.nature
    @task.started_on = template.started_on
    @task.ended_on = template.ended_on
    @task.assigned_to = template.assigned_to
  end
  
  def create
    @task = Task.new(params[:task])
    @task.created_by = current_user.id
    @task.project_id = current_project.id
        
    if @task.save
      @task.set_dates_from_params(params)
      Task.regenerate_priorities if not @task.archived?
      redirect_to tasks_path
    else
      render :action => 'new'
    end
  end
  
  def edit
    @task = Task.find(params[:id])
  end
  
  def update
    @task = Task.first(:conditions => { :id => params[:id] })
    
    if params[:insert_after]
      @task.insert_after(params[:insert_after])
      render :text => {'success' => params[:insert_after]}.to_json
    elsif params[:insert_first]
      @task.prioritize_to(1)
      render :text => {'success' => 1}.to_json
    elsif @task.update_attributes(params[:task])
      @task.set_dates_from_params(params)
      @task.set_archive_status!
      
      redirect_to tasks_path
    else
      render :action => "edit"
    end
  end
  
  def destroy
    Task.find(params[:id]).destroy
    Task.regenerate_priorities
    
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
      session[:task_archived] = false
    end
    @archived = session[:task_archived]
  end
end