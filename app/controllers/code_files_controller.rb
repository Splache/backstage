class CodeFilesController < ApplicationController
  before_filter :authenticated?
  layout 'standard'
  
  def index
    @code_files = CodeFile.all(:conditions => { :project_id => current_project.id })
  end
  
  def show
    @code_file = CodeFile.first(:conditions => { :id => params[:id] })
    
    dredirect_to('project.code_files') unless @code_file
  end
  
  def new
    template = CodeFile.last(:order => 'id ASC')
    
    @code_file = current_project.code_files.build
    @code_file.path = template.path
  end
  
  def create
    @code_file = CodeFile.new(params[:code_file])
    
    if @code_file.save
      dredirect_to('project.code_file', :action => 'new') 
    else
      render :action => 'new'
    end
  end
  
  def edit
    @code_file = CodeFile.find(params[:id])
  end
  
  def update
    @code_file = CodeFile.find(params[:id])
    
    if @code_file.update_attributes(params[:code_file])
      dredirect_to('project.code_file', :id => @code_file.id) 
    else
      render :action => "edit"
    end
  end
  
  def destroy
    CodeFile.find(params[:id]).destroy
    dredirect_to('project.code_files')
  end
end