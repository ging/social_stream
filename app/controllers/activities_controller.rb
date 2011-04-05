class ActivitiesController < InheritedResources::Base
  belongs_to_subjects
  actions :index

  respond_to :js

  protected

  def collection
    rel = params[:section].to_i if params[:section].present?

    # should be activities.paginate(:page => params[:page], :count => { :select => 'activity.id', :distinct => true }) but it is not working in Rails 3.0.3 
    @activities ||= association_chain[-1].
                      wall(:profile,
                           :for => current_subject,
                           :relation => rel).
                      paginate(:page => params[:page])
  end
end
