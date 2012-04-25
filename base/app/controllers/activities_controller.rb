class ActivitiesController < InheritedResources::Base
  actions :index

  respond_to :js

  protected

  def collection
    rel = params[:section].to_i if params[:section].present?

    # should be activities.page(params[:page], :count => { :select => 'activity.id', :distinct => true }) but it is not working in Rails 3.0.3 
    @activities ||= profile_subject.
                      wall(:profile,
                           :for => current_subject,
                           :relation => rel).
                      page(params[:page])
  end
end
