# Convenience class for managing like activities
class Like
  attr_reader :activity

  class << self
    # Find the children activity of activity_id liked by subject
    def find(subject, activity_id)
      find_activity(activity_id).liked_by(subject).first
    end

    # Like #find but raises error if not found
    def find!(subject, activity_id)
      find(subject, activity_id) ||
        raise(ActiveRecord::RecordNotFound)
    end

    # Find the activity that is liked
    def find_activity(id)
      Activity.find(id) ||
        raise(ActiveRecord::RecordNotFound)
    end
  end

  # Initialize a new like activity
  def initialize(subject, activity_id)
    @subject  = subject
    @activity = self.class.find_activity(activity_id)
    @like     = @activity.new_like(@subject)
  end

  def save
    @like.save
  end
end
