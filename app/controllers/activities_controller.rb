class ActivitiesController < ApplicationController
  def index
    if params[:wall].present?
      render :partial => 'wall', :section => params[:section] 
      return
    end
  end
end
