class DocumentsController < ApplicationController
  before_filter :authenticated?
  layout 'standard'
  
  def index
    @documents = Document.all
  end
  
  def show
    @document = Document.first(:conditions => { :id => params[:id] })
    
    dredirect_to('project.documents') unless @document
  end
  
  def new
    template = Document.last(:order => 'id ASC')
    
    @document = current_project.documents.build
  end
  
  def create
    @document = Document.new(params[:document])
    
    if @document.save
      dredirect_to('project.document', :action => 'new')
    else
      render :action => 'new'
    end
  end
  
  def edit
    @document = Document.find(params[:id])
  end
  
  def update
    @document = Document.find(params[:id])
    
    if @document.update_attributes(params[:document])
      dredirect_to('project.document', :id => @document.id)
    else
      render :action => "edit"
    end
  end
  
  def destroy
    Document.find(params[:id]).destroy
    dredirect_to('project.documents')
  end
end