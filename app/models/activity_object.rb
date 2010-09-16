class ActivityObject < ActiveRecord::Base
  include ActiveRecord::Supertype

  has_many :activity_object_activities, :dependent => :destroy
  has_many :activities, :through => :activity_object_activities
  has_one  :actor

  # The object of this activity object
  def object
    subtype_instance ||
      actor.try(:subject)
  end

  # The activity in which this activity_object was created
  def post_activity
    activities.includes(:activity_verb).where('activity_verbs.name' => 'post').first
  end
end
