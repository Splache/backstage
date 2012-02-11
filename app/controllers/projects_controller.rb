class ProjectsController < ApplicationController
  before_filter :authenticated?
  layout 'standard'

  def index

  end

  def show
    dredirect_to('project.tasks', :project_id => params[:id])
  end
end
