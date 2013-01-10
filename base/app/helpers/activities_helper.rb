module ActivitiesHelper
  # Link to 'like' or 'unlike' depending if current_subject already unlikes or likes
  # the object respectively
  #
  # @param [Object]
  # @return [String]
  def like_status object
    [ 'like', 'unlike' ].tap do |s|
      if user_signed_in? && object.liked_by?(current_subject)
        s.reverse!
      end
    end
  end

  # Build a new post based on the current_subject. Useful for authorization queries
  def new_post(receiver)
    return Post.new unless user_signed_in?

    Post.new :author_id => Actor.normalize_id(current_subject),
             :owner_id  => Actor.normalize_id(receiver)
  end

  def like_sentence(activity, options = {})
    options[:likers_shown] ||= 2

    # TODO: select likers from current_subject's contacts
    likers =
      activity.likes.first(options[:likers_shown]).
      map{ |a| a.sender_subject }.
      map{ |l| link_to l.name, l }

    likers_count = activity.likes.count
    likers_other = likers_count - options[:likers_shown]

    if likers_other > 0
      likers.push t("activity_action.sentence.more", :count => likers_other)
    end

    t("activity.like_sentence", :likers => likers.to_sentence, :count => likers_count).html_safe
  end
end
