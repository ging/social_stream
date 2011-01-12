module ActivitiesHelper

  # Link to 'like' or 'unlike' depending on the like status of the activity to current_subject
  # 
  # @param [Activity]
  # @return [String]
  def link_like(activity)
    if (activity.liked_by?(current_subject))
      link_to t('activity.unlike'), activity_like_path(activity), :method => :delete, :remote => true
    else
      link_to t('activity.like'), activity_like_path(activity), :method => :post, :remote => true
    end
  end
end
