# The {ActivityObject} is any object that receives actions. Examples are
# creating post, liking a comment, contacting a user. 
#
# = ActivityObject subtypes
# All post, comment and user are {SocialStream::Models::Object objects}.
# Social Stream privides 3 {ActivityObject} subtypes, {Post}, {Comment} and
# {Actor}. The application developer can define as many {ActivityObject} subtypes
# as required.
# Objects are added to +config/initializers/social_stream.rb+
#
class ActivityObject < ActiveRecord::Base
  @subtypes_name = :object
  include SocialStream::Models::Supertype

  acts_as_taggable
  
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
