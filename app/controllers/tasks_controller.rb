class TasksController < ApplicationController
  before_filter :authenticated?, :init_filters
  layout 'standard'
  
  def index
    @tasks = Task.all_from_filters(current_user, session[:task_filters])
    
    if request.format == 'js'
      #sleep 2
    end
    
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
    Task.regenerate_priorities(current_project.id)
    
    redirect_to tasks_path
  end
  
  def init_filters
    session[:task_filters] = { :assigned_to => current_user.id } if not session[:task_filters]
    
    if params[:filter]
      set_filter(:assigned_to)
      set_filter(:nature)
      set_filter(:move)
      set_filter(:archive)
      set_filter(:search)
    end
    
    @filters = session[:task_filters]
  end
  
  def set_filter(filter)
    if params[:filter][filter]
      session[:task_filters][filter] = params[:filter][filter] == '$remove$' ? nil : params[:filter][filter] 
    end
  end
end