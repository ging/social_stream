# Convenience class for managing like activities
class Like
  attr_reader :object

  class << self
    # Find the children activity of activity_id liked by subject
    def find(subject, object)
      like = new(object.liked_by(subject).readonly(false).first)
      return nil if like.object.nil?
      # Cache object to make it available before it is destroyed
      like.object
      like
    end

    # Like #find but raises error if not found
    def find!(subject, object)
      find(subject, object) ||
        raise(ActiveRecord::RecordNotFound)
    end

    def build(subject, user, object)
       l = self.find(subject,object)
       l = new object.new_like(subject, user) if l.nil?
       l
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
      if @like.nil?
        nil
      elsif @like.is_root?
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
