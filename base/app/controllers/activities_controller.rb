class ActivitiesController < ApplicationController
  def index
    # should be activities.page(params[:page], :count => { :select => 'activity.id', :distinct => true }) but it is not working in Rails 3.0.3 
    @activities ||= profile_subject.
                      wall(:profile,
                           :for => current_subject).
                      page(params[:page])

    respond_to do |format|
      format.js
      format.atom
    end
  end
end
