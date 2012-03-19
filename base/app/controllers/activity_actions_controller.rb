class ActivityActionsController < ApplicationController
  # Last tendencies in rails talk about filtering params in the controller,
  # instead of using attr_protected
  #
  # We hope it will be shiped in Rails 4, so we write our custom method for now
  before_filter :clean_params

  before_filter :can_read_activity_object, :only => :create

  respond_to :js

  def create
    @activity_action =
      current_subject.
        sent_actions.
        find_or_create_by_activity_object_id @activity_object.id

    @activity_action.update_attributes params[:activity_action]
  end

  def update
    activity_action.update_attributes params[:activity_action]
  end

  private

  def clean_params
    return if params[:activity_action].blank?

    params[:activity_action].delete(:actor_id)
    params[:activity_action].delete(:activity_object_id) if params[:id].present?
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
