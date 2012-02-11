class CodeMethodsController < ApplicationController
  before_filter :authenticated?
  layout 'standard'

  def edit
    @code_method = CodeMethod.find(params[:id])
  end

  def update
    @code_method = CodeMethod.find(params[:id])

    if @code_method.update_attributes(params[:code_method])
      dredirect_to('project.code_file', :id => @code_method.code_file.id)
    else
      render :action => "edit"
    end
  end

  def generate
    CodeMethod.destroy_all("code_file_id = #{params[:code_file_id]}")
    CodeMethod.extract_from_file(params[:code_file_id])
    dredirect_to('project.code_file', :id => params[:code_file_id])
  end
end
