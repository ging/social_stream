module ActivitiesHelper

  def like_activity(activity)
    if (activity.liked_by?(current_user))
      link_to t('activity.unlike'), activity_like_path(activity), :method => :delete, :remote => true
    else
      link_to t('activity.like'), activity_like_path(activity), :method => :post, :remote => true
    end
  end
end
