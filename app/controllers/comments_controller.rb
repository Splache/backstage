class CommentsController < ApplicationController
  before_filter :authenticated?
  layout 'standard'
  
  def index
    @comments = Comment.all(:conditions => { :task_id => params[:task_id] })

    render :layout => false
  end
  
  def show
    
  end
  
  def new
    
  end
  
  def create
    comment = Comment.new
    comment.user_id = current_user.id
    comment.task_id = params[:task_id]
    comment.description = params[:comment][:description]
    
    if comment.save
      render :text => 'success', :status => '200'
    else
      render :text => 'error', :status => '400'
    end
  end
  
  def edit
    
  end
  
  def update
    comment = Comment.first(:conditions => { :id => params[:id] })
    
    comment.description = params[:comment][:description]
    
    if comment.save
      render :text => 'success', :status => '200'
    else
      render :text => 'error', :status => '400'
    end
  end
  
  def destroy
    Comment.find(params[:id]).destroy
    
    render :text => 'success', :status => '200'
  end
end