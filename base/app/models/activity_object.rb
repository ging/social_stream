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
  # ActivityObject is a subtype of Channel
  # Author, owner and user_author of this ActivityObject are defined in its channel
  subtype_of :channel,
             :belongs => { :dependent => nil }
  # ActivityObject is a supertype of SocialStream.objects
  supertype_of :object

  acts_as_taggable

  has_many :activity_object_activities, :dependent => :destroy
  has_many :activities, :through => :activity_object_activities

  validates_presence_of :object_type

  scope :authored_by, lambda { |subject|
    joins(:channel).merge(Channel.authored_by(subject))
  }

  before_validation :check_existing_channel

  # The object of this activity object
  def object
    subtype_instance.is_a?(Actor) ?
      subtype_instance.subject :
      subtype_instance
  end

  # The activity in which this activity_object was created
  def post_activity
    activities.includes(:activity_verb).where('activity_verbs.name' => 'post').first
  end

  # Does this {ActivityObject} has {Actor}?
  def acts_as_actor?
    object_type == "Actor"
  end

  protected

  def check_existing_channel
    return unless channel!.new_record?

    existing_channel =
      Channel.
        where(:author_id      => author_id,
              :owner_id       => owner_id,
              :user_author_id => user_author_id).
        first

    return if existing_channel.blank?

    self.channel = existing_channel
  end
end
