# This model includes all the actions performed by {Actor actors}
# on {ActivityObject activity objects}
# 
class ActivityAction < ActiveRecord::Base
  belongs_to :actor
  belongs_to :activity_object

  scope :sent_by, lambda{ |actor|
    where(:actor_id => Actor.normalize_id(actor))
  }

  scope :not_sent_by, lambda{ |actor|
    where(arel_table[:actor_id].not_in(Actor.normalize_id(actor)))
  }

  scope :received_by, lambda{ |activity_object|
    where(:activity_object_id => ActivityObject.normalize_id(activity_object))
  }

  scope :authored_or_owned, where(arel_table[:author].eq(true).
                                or(arel_table[:user_author].eq(true)).
                                or(arel_table[:owner].eq(true)))

  scope :authored_or_owned_by, lambda{ |subject|
    authored_or_owned.sent_by(subject)
  }


  before_create :follow_by_author_and_owner

  after_save :change_follower_count

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
