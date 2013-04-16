class ActivitiesController < ApplicationController
  def index
    # should be activities.page(params[:page], :count => { :select => 'activity.id', :distinct => true }) but it is not working in Rails 3.0.3 
    @activities =
      Activity.timeline(current_section,
                        current_subject).
               page(params[:page])

    respond_to do |format|
      format.html { render @activities }
      format.atom
    end
  end

  def show
    activity = Activity.find(params[:id])

    redirect_to activity.direct_object || activity.receiver_subject
  end

  private

  def current_section
    return :home if params[:section] == "home"

    return profile_subject if profile_subject.present?
  end
end
