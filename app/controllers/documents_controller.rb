class DocumentsController < ApplicationController
  before_filter :authenticated?
  layout 'standard'
  
  def index
    @documents = Document.all
  end
  
  def show
    @document = Document.first(:conditions => { :id => params[:id] })
    
    redirect_to documents_path unless @document
  end
  
  def new
    template = Document.last(:order => 'id ASC')
    
    @document = current_project.documents.build
  end
  
  def create
    @document = Document.new(params[:document])
    
    if @document.save
      redirect_to new_document_path
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
      redirect_to document_path(@document)
    else
      render :action => "edit"
    end
  end
  
  def destroy
    Document.find(params[:id]).destroy
    redirect_to documents_path
  end
end