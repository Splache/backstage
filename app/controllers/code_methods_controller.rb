class CodeMethodsController < ApplicationController
  before_filter :authenticated?
  layout 'standard'
  
  def generate
    CodeMethod.destroy_all("code_file_id = #{params[:code_file_id]}")
    CodeMethod.extract_from_file(params[:code_file_id])
    redirect_to code_file_path(params[:code_file_id])
  end
end