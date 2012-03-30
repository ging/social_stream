# This model includes all the actions performed by {Actor actors}
# on {ActivityObject activity objects}
# 
class ActivityAction < ActiveRecord::Base
  belongs_to :actor
  belongs_to :activity_object

  before_save :change_follower_count

  scope :sent_by, lambda{ |actor|
    where(:actor_id => Actor.normalize_id(actor))
  }

  scope :received_by, lambda{ |activity_object|
    where(:activity_object_id => ActivityObject.normalize_id(activity_object))
  }

  before_create :follow_by_author_and_owner

  private

  # Updates the follower_count counter in the {ActivityObject}
  def change_follower_count
    return unless follow_changed?

    follow? ?
      activity_object.increment!(:follower_count) :
      activity_object.decrement!(:follower_count)
  end

  def follow_by_author_and_owner
    self.follow = true if author? || user_author? || owner?
  end
end
