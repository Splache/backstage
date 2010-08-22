class TasksController < ApplicationController
  before_filter :authenticated?, :init_options
  layout 'standard'
  
  def index
    @tasks = Task.all_from_options(current_user, session[:task_options])
    
    @comment = Comment.new
    @comment.user_id = current_user.id
  end
  
  def show
    
  end
  
  def new
    template = Task.last(:order => 'id ASC')
    
    @task = current_project.tasks.build
    @task.nature = template.nature
    @task.assigned_to = template.assigned_to
  end
  
  def create
    @task = Task.new(params[:task])
    @task.priority = 1
    @task.created_by = current_user.id
    @task.project_id = current_project.id
    if @task.save
      @task.set_dates_from_params(params)
      @task.set_identifier
      Task.regenerate_priorities(current_project.id, :skip_task => @task) if not @task.archived?
      dredirect_to('project.tasks')
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
      dredirect_to('project.tasks')
    else
      render :action => "edit"
    end
  end
  
  def destroy
    Task.find(params[:id]).destroy
    Task.regenerate_priorities(current_project.id)
    
    dredirect_to('project.tasks')
  end
  
  def init_options
    session[:task_options] = { :archive => 0, :assigned_to => current_user.id, :template => 'item-full' } if not session[:task_options]
    
    if params[:option]
      set_option(:assigned_to)
      set_option(:nature)
      set_option(:move)
      set_option(:archive)
      set_option(:search)
      set_option(:template)
    end
    
    @options = session[:task_options]
  end
  
  def set_option(option)
    if params[:option][option]
      session[:task_options][option] = params[:option][option] == '$remove$' ? nil : params[:option][option] 
    end
  end
end