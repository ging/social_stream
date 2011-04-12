# Convenience class for managing like activities
class Like
  attr_reader :object

  class << self
    # Find the children activity of activity_id liked by subject
    def find(subject, object)
      like = new(object.liked_by(subject).first)
      # Cache object to make it available before it is destroyed
      like.object
      like
    end

    # Like #find but raises error if not found
    def find!(subject, object)
      find(subject, object) ||
        raise(ActiveRecord::RecordNotFound)
    end

    def build(subject, object)
       new object.new_like(subject)
    end
  end

  # Initialize a new like activity
  def initialize(activity)
    @like = activity
  end

  def save
    @like.save
  end
  
  # The object that is liked. It can be an activity
  def object
    @object ||=
      if @like.is_root?
        obj = @like.direct_object
        obj = obj.subject if obj.is_a?(Actor)
        obj
      else
        @like.parent
      end
  end
  
  def destroy
    @like.destroy
  end
end
