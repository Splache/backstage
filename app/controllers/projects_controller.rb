class ProjectsController < ApplicationController
  before_filter :authenticated?
  layout 'standard'
  
  def index
    
  end
  
  def show
    session[:current_project] = params[:id]
    redirect_to code_files_path
  end
end