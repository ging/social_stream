class ActivityObjectActivity < ActiveRecord::Base
  belongs_to :activity, :dependent => :destroy
  belongs_to :activity_object

  before_create :default_object_type

  private
  
  # Default objects are direct objects. http://activitystrea.ms/head/atom-activity.html#activity.object
  # Other type of objects are targets.  http://activitystrea.ms/head/atom-activity.html#activity.target
  def default_object_type
    self.object_type ||= "object"
  end
end
