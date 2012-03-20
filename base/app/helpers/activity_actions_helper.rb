module ActivityActionsHelper
  def toggle_follow_action(activity_object)
    action = activity_object.action_from(current_subject)
    action ||= activity_object.received_actions.build :actor_id => current_subject.actor_id

    action.follow ^= true

    action
  end

  # Show the {SocialStream::Models::Subject Subjects} that follow
  # the {ActivityObject object}
  #
  # TODO: DRY with ActivitiesHelper#like_sentence
  def followers_sentence(object, options = {})
    options[:followers_shown] ||= 2

    followers_count = object.follower_count

    return "" unless followers_count > 0

    followers =
      object.followers.
      map{ |a| a.subject }.
      map{ |l| link_to l.name, l }

    followers_other = followers_count - options[:followers_shown]

    if followers_other > 0
      followers.push t("activity_action.sentence.more", :count => followers_other)
    end

    t("#{ object.object_type.underscore }.activity_action.sentence.follow", :followers => followers.to_sentence, :count => followers_count, :default => :"activity_action.sentence.follow").html_safe
  end
end
