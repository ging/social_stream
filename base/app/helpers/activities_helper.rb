module ActivitiesHelper
  # Link to 'like' or 'unlike' depending on the like status of the activity to current_subject
  #
  # @param [Object]
  # @return [String]
  def link_like(object)
    params = link_like_params(object)
    link_to params[0],params[1],params[2]
  end

  def link_like_params(object)
    params = Array.new
    if !user_signed_in?
      params << image_tag("btn/nolike.png", :class => "menu_icon")+t('activity.like')
      params << new_user_session_path
      params << {:class => "verb_like",:id => "like_" + dom_id(object)}
    else
      if (object.liked_by?(current_subject))
        params << image_tag("btn/like.png", :class => "menu_icon")+t('activity.unlike')
        params << [object, :like]
        params << {:class => "verb_like",:id => "like_" + dom_id(object),:method => :delete, :remote => true}
      else
        params << image_tag("btn/nolike.png", :class => "menu_icon")+t('activity.like')
        params << [object, :like]
        params << {:class => "verb_like",:id => "like_" + dom_id(object),:method => :post, :remote => true}
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
