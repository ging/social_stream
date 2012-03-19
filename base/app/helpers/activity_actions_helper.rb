module ActivityActionsHelper
  def toggle_follow_action(activity_object)
    action = activity_object.action_from(current_subject)
    action ||= activity_object.received_actions.build :actor_id => current_subject.actor_id

    action.follow ^= true

    action
  end
end
