class AudienceController < ApplicationController
  before_filter :read_activity

  respond_to :js

  def index
  end

  private

  def read_activity
    @activity = Activity.find params[:activity_id]

    authorize! :read, @activity
  end
end
