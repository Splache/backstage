class CodeFilesController < ApplicationController
  before_filter :authenticated?
  layout 'standard'
  
  def index
    @code_files = CodeFile.all
  end
  
  def show
    @code_file = CodeFile.first(:conditions => { :id => params[:id] })
    
    redirect_to code_files_path unless @code_file
  end
  
  def new
    template = CodeFile.last(:order => 'id ASC')
    
    @code_file = current_project.code_files.build
    @code_file.path = template.path
  end
  
  def create
    @code_file = CodeFile.new(params[:code_file])
    
    if @code_file.save
      redirect_to new_code_file_path
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
      redirect_to code_file_path(@code_file)
    else
      render :action => "edit"
    end
  end
  
  def destroy
    CodeFile.find(params[:id]).destroy
    redirect_to code_files_path
  end
end