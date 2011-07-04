module ActivitiesHelper
  
  # Link to 'like' or 'unlike' depending on the like status of the activity to current_subject
  # 
  # @param [Object]
  # @return [String]
  def link_like(object)
    if !user_signed_in?
      link_to image_tag("btn/nolike.png", :class => "menu_icon")+ 
                t('activity.like'),new_user_session_path
    else
      if (object.liked_by?(current_subject))
        link_to image_tag("btn/like.png", :class => "menu_icon")+ 
                t('activity.unlike'), [object, :like], :method => :delete, :remote => true
      else
        link_to image_tag("btn/nolike.png", :class => "menu_icon")+ 
                t('activity.like'), [object, :like], :method => :post, :remote => true
      end
    end
  end

  # Build a new activity based on the current_subject. Useful for authorization queries
  def new_activity(receiver)
    return Activity.new unless user_signed_in?

    Activity.new :contact_id => current_subject.contact_to!(receiver).id,
                 :relation_ids => current_subject.activity_relations(receiver, :from => :receiver).map(&:id)
  end
end
