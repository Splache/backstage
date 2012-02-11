class ActivityReportsController < ApplicationController
  before_filter :authenticated?
  layout 'standard'

  def create
    ActivityReport.send_for_user(current_user)

    redirect_to :back
  end
end
