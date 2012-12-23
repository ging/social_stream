class ActivityActionsController < ApplicationController
  before_filter :can_read_activity_object, :only => :create

  respond_to :js

  def create
    @activity_action =
      current_subject.
        sent_actions.
        find_or_create_by_activity_object_id @activity_object.id

    @activity_action.update_attributes activity_action_params
  end

  def update
    activity_action.update_attributes activity_action_params
  end

  private

  def activity_action_params
    params.
      require(:activity_action).
      permit(:follow)
  end

  def can_read_activity_object
    @activity_object = ActivityObject.find(params[:activity_action][:activity_object_id])

    authorize! :read, @activity_object.object
  end

  def activity_action
    @activity_action ||=
      current_subject.sent_actions.find params[:id]
  end
end
