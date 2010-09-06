class ActivityObject < ActiveRecord::Base
  include ActiveRecord::Supertype

  has_many :activity_object_activities
  has_many :activities, :through => :activity_object_activities
  has_one  :actor

  def object
    subtype_instance ||
      actor.try(:subject)
  end
end
