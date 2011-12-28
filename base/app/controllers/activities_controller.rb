class ActivitiesController < InheritedResources::Base
  belongs_to_subjects
  actions :index

  respond_to :js

  def edit
    @activity = Activity.find(params[:id])
    @aoa = ActivityObjectActivity.find_by_activity_id(params[:id])
    @activity_object = ActivityObject.find(@aoa.activity_object_id) if @aoa
    respond_to do |format|
      format.html { render :partial => 'activities/edit' }
      format.json { head :ok }
    end
  end

  def update
    @activity = Activity.find(params[:id])
    respond_to do |format|
      if @activity.update_attributes(params[:activity])
        format.html { redirect_to current_subject, notice: 'Activity was successfully updated.' }
	format.json { head :ok }
      else
        format.html { render action: "edit" }
	format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  protected

  def collection
    rel = params[:section].to_i if params[:section].present?

    # should be activities.page(params[:page], :count => { :select => 'activity.id', :distinct => true }) but it is not working in Rails 3.0.3 
    @activities ||= association_chain[-1].
                      wall(:profile,
                           :for => current_subject,
                           :relation => rel).
                      page(params[:page])
  end
end
